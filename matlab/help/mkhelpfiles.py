#!/usr/bin/python
# -*- coding: utf-8 -*-
# Filename: mkhelpfiles.py


"""
  mkhelpfiles.py

  Build MATLAB help files based on XML TOC.

  Usage: mkhelpfiles.py -i helptoc.xml

  M Hewitson 01-03-07

  $Id$

"""


import glob
import os
import sys
from   string import *
import getopt
import platform
import time
import datetime


def extract(text, sub1, sub2):
    """extract a substring between two substrings sub1 and sub2 in text"""
    print(text.split(sub1))
    return text.split(sub1)[-1].split(sub2)[0]

#######################################################################
#
# mkdir
#
def _mkdir(newdir):
  """works the way a good mkdir should :)
      - already exists, silently complete
      - regular file in the way, raise an exception
      - parent directory(ies) does not exist, make them as well
  """
  if os.path.isdir(newdir):
    pass
  elif os.path.isfile(newdir):
    raise OSError("a file with the same name as the desired " \
              "dir, '%s', already exists." % newdir)
  else:
    head, tail = os.path.split(newdir)
    if head and not os.path.isdir(head):
      _mkdir(head)
    #print "_mkdir %s" % repr(newdir)
    if tail:
      os.mkdir(newdir)
  return None;



######################################################################
#  Main
#
def main():

  try:
    opts, args = getopt.getopt(sys.argv[1:], "i:", ["input="])
  except getopt.GetoptError:
    print(__doc__)
    sys.exit(2)

  # Default settings for database
  tocfile   = ''

  # process args
  for o, a in opts:
    if o in ("-i", "--input"):
      tocfile = a

  # check for required fields
  if tocfile=="":
    print("\n### Incorrect inputs.")
    print(__doc__)
    sys.exit(2)

  # Load XML file
  try:
    fin = open(tocfile);
    allLines = fin.readlines();
    fin.close()
  except IOError:
    print("# error opening file.")
    sys.exit(-1)

  # Load Template file
  try:
    fin = open('template.html');
    templateFile = fin.read();
    fin.close()
  except IOError:
    print("# error opening file.")
    sys.exit(-1)

  # Go through each line and look for 'target='
  entries = [];

  for l in allLines:
    line = strip(l)
    if 'target=' in line and not 'useHtmlTemplate="false"' in line :
      tmp      = split(line, "<")[1].split(">");
      title    = strip(tmp[1])
      htmlfile = strip(tmp[0].split('"')[1])

      # If this is an html file we can continue
      if htmlfile.endswith('.html'):
        print "%s - %s" % (htmlfile, title)

        entry = {}
        entry["html"]  = htmlfile
        entry["title"] = title
        entries.append(entry)


  for j in range(0,len(entries)):
    entry = entries[j]
    print("--- Processing %s ------------------------" % entry)
    htmlfile = entry["html"]
    title    = entry["title"]

    if len(split(htmlfile, '/')) == 2:
      outdir  = split(htmlfile, '/')[0]
      outfile = split(htmlfile, '/')[1]
      _mkdir(outdir)
    else:
      outdir = ''
      outfile = split(htmlfile, '/')[0]

    # insert title
    html = templateFile;
    html = html.replace(">TITLE", ">%s"%title)

    # insert pre_title
    if j>=1:
      lastentry = entries[j-1]
    else:
      lastentry = entries[-1]

    last = split(lastentry["html"], '/')[-1]
    print("PRE: inserting %s" % last)
    html = html.replace("PRE_TITLE", lastentry["title"])

    # insert prehtml
    html = html.replace("prehtml.html", last)

    # insert post_title
    if j<len(entries)-1:
      nextentry = entries[j+1]
    else:
      nextentry = entries[0]

    # print "POST: inserting %s" % split(nextentry["html"], '/')[-1]
    next = split(nextentry["html"], '/')[-1]
    print("POST: inserting %s" % next)
    html = html.replace("POST_TITLE", nextentry["title"])

    # insert posthtml
    html = html.replace("posthtml.html", next)

    # insert content link
    contentFilePath = split(htmlfile, '.html')[0]+'_content.html'
    if len(split(contentFilePath, '/'))>1:
      conoutdir = split(contentFilePath, '/')[0]
      conout    = split(contentFilePath, '/')[1]
    else:
      conoutdir = ''
      conout    = split(contentFilePath, '/')[0]



    # make contents version of htmlfile
    # - only if file doesn't exist
    if os.path.exists(contentFilePath):
      try:
        fin = open(contentFilePath);
        line1 = fin.readline();
        if line1.startswith("<!-- $Id:"):
					line1 = ""
        content = line1+fin.read();
        fin.close()
      except IOError:
        print("# error opening file.")
        sys.exit(-1)
    else:
      content = "<p>Content needs written...</p>"

    html = html.replace("CONTENT", content)
    # write out
    fout = open(htmlfile, "w+");
    fout.write(html)
    fout.close();

# call main
if __name__ == "__main__":
    main()
