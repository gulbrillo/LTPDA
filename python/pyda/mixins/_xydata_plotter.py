#  Copyright 2022 Martin Hewitson
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


import numpy
import matplotlib.pyplot as plt
import pyda


class XYDataPlotter:
    def loglog(self, *args, **kwargs):
        """
        Plot FSData objects on loglog axes. For complex objects, magnitude/phase subplots will be generated,
        both with log-scale x axes and log-scale magnitude y-axis, and linear scale phase y-axis.

        ErrorType = "bar" or "area"

        :param args: List of objects to plot
        :param kwargs: Additional arguments for plot configuration. Options: FigSize, ErrorType, ax...
        :return: a list with (figure handle, list of axis handles, list of errorbar handles)
        """
        h = self._plot(args, kwargs)

        fh = h[0]
        axes = h[1]

        for ax in axes:
            ax.set_xscale("log")

        axes[0].set_yscale("log")

        return h

    def semilogy(self, *args, **kwargs):
        """
        Plot XYData objects on semilogy axes. For complex objects, magnitude/phase subplots will be generated.

        ErrorType = "bar" or "area"

        :param args: List of objects to plot
        :param kwargs: Additional arguments for plot configuration. Options: FigSize, ErrorType, ax...
        :return: a list with (figure handle, list of axis handles, list of errorbar handles)
        """
        h = self._plot(args, kwargs)

        fh = h[0]
        axes = h[1]

        for ax in axes:
            ax.set_yscale("log")

        return h

    def semilogx(self, *args, **kwargs):
        """
        Plot XYData objects on semilogx axes. For complex objects, magnitude/phase subplots will be generated.

        ErrorType = "bar" or "area"

        :param args: List of objects to plot
        :param kwargs: Additional arguments for plot configuration. Options: FigSize, ErrorType, ax...
        :return: a list with (figure handle, list of axis handles, list of errorbar handles)
        """
        h = self._plot(args, kwargs)

        fh = h[0]
        axes = h[1]

        for ax in axes:
            ax.set_xscale("log")

        return h

    def plot(self, *args, **kwargs):
        """
        Plot XYData objects on linear axes. For complex objects, magnitude/phase subplots will be generated.

        ErrorType = "bar" or "area"

        :param args: List of objects to plot
        :param kwargs: Additional arguments for plot configuration. Options: FigSize, ErrorType, ax...
        :return: a list with (figure handle, list of axis handles, list of errorbar handles)
        """
        h = self._plot(args, kwargs)
        return h

    def _plot(self, args, kwargs):
        ts = self

        # Process arguments
        FigSize = None
        ShowErrors = False
        ErrorType = "bar"
        ax = None

        for key, value in kwargs.items():
            if key.lower() == "figsize":
                FigSize = value
            if key.lower() == "showerrors":
                ShowErrors = True
            if key.lower() == "errortype":
                ErrorType = value
            if key.lower() == "ax":
                ax = value

        # collect axis errorbar handles
        ebhs = []
        axhs = []
        f = None

        if any(numpy.iscomplex(ts.ydata())):
            if ax is None:
                f, (ax1, ax2) = plt.subplots(2, 1, figsize=FigSize)
            else:
                # For complex data, we need two axes
                if isinstance(ax, (list, tuple)) and len(ax) >= 2:
                    ax1, ax2 = ax[0], ax[1]
                    f = ax1.figure
                else:
                    # If only one axis is provided, create a second one
                    f = ax.figure
                    ax1 = ax
                    # Create ax2 below ax1
                    bbox = ax1.get_position()
                    ax2 = f.add_axes([bbox.x0, bbox.y0 - bbox.height, bbox.width, bbox.height])

            axhs.append(ax1)
            axhs.append(ax2)

            if ShowErrors:
                ebh1, ebh2 = XYDataPlotter._plot_complex_object_with_errors(
                    ts, ax1, ax2, ErrorType
                )
                ebhs.append(ebh1)
                ebhs.append(ebh2)

                for t in args:
                    if not isinstance(t, XYDataPlotter):
                        print("! Skipping non XYData " + str(t))
                    else:
                        ebh1, ebh2 = XYDataPlotter._plot_complex_object_with_errors(
                            t, ax1, ax2, ErrorType
                        )
                        ebhs.append(ebh1)
                        ebhs.append(ebh2)
            else:
                XYDataPlotter._plot_complex_object(ts, ax1, ax2)

                for t in args:
                    if not isinstance(t, pyda.xydata.XYData):
                        print("! Skipping non XYData " + str(t))
                    else:
                        XYDataPlotter._plot_complex_object(t, ax1, ax2)

            ax1.set_ylabel(ts.yaxis.name + " " + ts.yunitsLabel())
            ax1.grid(visible=True)
            ax1.legend()
            ax2.grid(visible=True)
            ax2.legend()
            ax2.set_ylabel("Phase (º)")
            ax2.set_xlabel(ts.xaxis.name + " " + ts.xunitsLabel())
        else:
            if ax is None:
                f, ax1 = plt.subplots(1, 1, figsize=FigSize)
            else:
                ax1 = ax
                f = ax1.figure

            axhs.append(ax1)

            if ShowErrors:
                ebh1 = XYDataPlotter._plot_object_with_errors(ts, ax1, ErrorType)
                ebhs.append(ebh1)

                for t in args:
                    if not isinstance(t, pyda.xydata.XYData):
                        print("! Skipping non XYData " + str(t))
                    else:
                        ebh1 = XYDataPlotter._plot_object_with_errors(t, ax1, ErrorType)
                        ebhs.append(ebh1)
            else:
                XYDataPlotter._plot_object(ts, ax1)

                for t in args:
                    if not isinstance(t, pyda.xydata.XYData):
                        print("! Skipping non XYData " + str(type(t)))
                    else:
                        XYDataPlotter._plot_object(t, ax1)

            ax1.set_xlabel(ts.xaxis.name + " " + ts.xunitsLabel())
            ax1.set_ylabel(ts.yaxis.name + " " + ts.yunitsLabel())
            ax1.grid(visible=True)
            ax1.legend()

        return [f, axhs, ebhs]

    @classmethod
    def _plot_complex_object(cls, ts, ax1, ax2):

        ax1.plot(
            ts.xdata(),
            numpy.abs(ts.ydata()),
            label=ts.name,
            color=ts.color,
            linestyle=ts.linestyle,
            linewidth=ts.linewidth,
            marker=ts.marker,
        )
        ax2.plot(
            ts.xdata(),
            numpy.angle(ts.ydata()) * 180.0 / numpy.pi,
            label=ts.name,
            color=ts.color,
            linestyle=ts.linestyle,
            linewidth=ts.linewidth,
            marker=ts.marker,
        )

    @classmethod
    def _plot_object(cls, ts, ax1):

        ax1.plot(
            ts.xdata(),
            ts.ydata(),
            label=ts.name,
            color=ts.color,
            linestyle=ts.linestyle,
            linewidth=ts.linewidth,
            marker=ts.marker,
        )

    @classmethod
    def _plot_object_with_errors(cls, ts, ax1, ErrorType):

        # errorbar() doesn't interpret a list of length 1 as a scalar :(
        xerr = ts.xaxis.ddata
        if xerr.size == 1:
            xerr = xerr[0]

        yerr = ts.yaxis.ddata
        if yerr.size == 1:
            yerr = yerr[0]
        elif yerr.size == 0:
            yerr = 0

        x = ts.xdata()
        y = ts.ydata()

        ebh1 = None

        if ErrorType.lower() == "bar":
            ebh1 = ax1.errorbar(
                x,
                y,
                xerr=xerr,
                yerr=yerr,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
        elif ErrorType.lower() == "area":
            (lh,) = ax1.plot(
                x,
                y,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ax1.fill_between(x, y - yerr, y + yerr, facecolor=lh.get_color(), alpha=0.2)
        else:
            raise Exception("Unknown ErrorType " + ErrorType)

        return ebh1

    @classmethod
    def _plot_complex_object_with_errors(cls, ts, ax1, ax2, ErrorType):

        # errorbar() doesn't interpret a list of length 1 as a scalar :(
        xerr = ts.xaxis.ddata
        if xerr.size == 1:
            xerr = xerr[0]

        yerr = ts.yaxis.ddata
        if yerr.size == 1:
            yerr = yerr[0]
        elif yerr.size == 0:
            yerr = 0

        x = ts.xdata()
        y1 = numpy.abs(ts.ydata())
        y2 = numpy.angle(ts.ydata()) * 180.0 / numpy.pi

        yerr1 = numpy.abs(yerr)
        yerr2 = numpy.angle(yerr) * 180.0 / numpy.pi

        ebh1 = None
        ebh2 = None

        if ErrorType.lower() == "bar":
            ebh1 = ax1.errorbar(
                x,
                y1,
                xerr=xerr,
                yerr=yerr1,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ebh2 = ax2.errorbar(
                x,
                y2,
                xerr=xerr,
                yerr=yerr2,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
        elif ErrorType.lower() == "area":
            (lh,) = ax1.plot(
                x,
                y1,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ax1.fill_between(
                x, y1 - yerr, y1 + yerr, facecolor=lh.get_color(), alpha=0.2
            )
            (lh,) = ax2.plot(
                x,
                y2,
                label=ts.name,
                color=ts.color,
                linestyle=ts.linestyle,
                linewidth=ts.linewidth,
                marker=ts.marker,
            )
            ax2.fill_between(
                x, y1 - yerr, y1 + yerr, facecolor=lh.get_color(), alpha=0.2
            )
        else:
            raise Exception("Unknown ErrorType " + ErrorType)

        return ebh1, ebh2
