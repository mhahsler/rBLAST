#######################################################################
# rBLAST - Interfaces to BLAST
# Copyright (C) 2015 Michael Hahsler and Anurag Nagar
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# finds the path to any of the executable listed in exe and returns the
# first one. Throws an error if interactive and non is found.
.findExecutable <- function(exe, interactive = TRUE) {
    path <- Sys.which(exe)
    if (!any(nzchar(path))) {
        if (interactive) {
            stop(
                "Executable for ",
                paste(exe, collapse = " or "),
                " not found!",
                " Please make sure that the software is correctly installed",
                " and, if necessary, path variables are set.",
                call. = FALSE
            )
        }
        return(structure("", name = exe[1]))
    }

    path[which(nzchar(path))[1]]
}
