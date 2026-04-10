package com.ltpda.ssh;

import com.jcraft.jsch.UserInfo;
import com.jcraft.jsch.UIKeyboardInteractive;

/**
 * JSch UserInfo + UIKeyboardInteractive implementation for LTPDA.
 *
 * Handles both plain password authentication and keyboard-interactive MFA
 * (e.g. Duo Push on HiPerGator or other institutional HPC clusters).
 *
 * Used by utils.ssh.ensureTunnel via:
 *   session.setUserInfo(new LTPDAUserInfo(password))
 */
public class LTPDAUserInfo implements UserInfo, UIKeyboardInteractive {

    private final String password;

    public LTPDAUserInfo(String password) {
        this.password = password;
    }

    // ── UserInfo ──────────────────────────────────────────────────────────────

    @Override public String  getPassword()              { return password; }
    @Override public String  getPassphrase()            { return "";       }
    @Override public boolean promptPassword(String m)   { return true;     }
    @Override public boolean promptPassphrase(String m) { return true;     }

    @Override
    public boolean promptYesNo(String message) {
        // Called when StrictHostKeyChecking=ask and host is not in known_hosts.
        // Accept because the server was explicitly configured by the user.
        System.out.println("LTPDA SSH: accepting unknown host — " + message);
        return true;
    }

    @Override
    public void showMessage(String message) {
        System.out.println("LTPDA SSH: " + message);
    }

    // ── UIKeyboardInteractive ─────────────────────────────────────────────────

    /**
     * Respond to server keyboard-interactive challenges.
     *
     * Handles:
     *   "password"        prompts → supply password silently
     *   Duo-style prompts         → show a dialog with the server's options list;
     *                               default is "1" (Push), user can change to "2"
     *                               or type a passcode
     *   Unknown prompts           → supply password as fallback
     */
    @Override
    public String[] promptKeyboardInteractive(
            String destination, String name, String instruction,
            String[] prompt, boolean[] echo) {

        if (prompt == null || prompt.length == 0) return new String[0];

        String p = prompt[0].toLowerCase();

        if (p.contains("password")) {
            return new String[]{password};

        } else if (p.contains("duo")            ||
                   p.contains("passcode")        ||
                   p.contains("(1-")             ||
                   p.contains("enter a number")) {

            // Build the message shown in the dialog: server instruction + prompt line
            String msg = (instruction != null && !instruction.trim().isEmpty())
                       ? instruction.trim() + "\n\n" + prompt[0]
                       : prompt[0];

            System.out.println("LTPDA SSH MFA: showing Duo options dialog");

            String choice = (String) javax.swing.JOptionPane.showInputDialog(
                null, msg,
                "LTPDA SSH MFA",
                javax.swing.JOptionPane.PLAIN_MESSAGE,
                null, null, "1");

            if (choice == null || choice.trim().isEmpty()) {
                System.out.println("LTPDA SSH MFA: cancelled by user");
                return null;  // null aborts keyboard-interactive auth
            }
            choice = choice.trim();
            System.out.println("LTPDA SSH MFA: user entered: " + choice);
            return new String[]{choice};

        } else {
            System.out.println("LTPDA SSH: unknown prompt \"" + prompt[0] + "\" — responding with password");
            return new String[]{password};
        }
    }
}
