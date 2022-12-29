// Copyright (C) 2022 Vladislav Nepogodin
//
// This file is part of CachyOS kernel manager.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#include "km-window.hpp"

#include <QApplication>
#include <QSharedMemory>

bool IsInstanceAlreadyRunning(QSharedMemory& memoryLock) {
    if (!memoryLock.create(1)) {
        memoryLock.attach();
        memoryLock.detach();

        if (!memoryLock.create(1)) {
            return true;
        }
    }

    return false;
}

int main(int argc, char** argv)
{
    // Set application info
    QCoreApplication::setOrganizationName("CachyOS");
    QCoreApplication::setApplicationName("CachyOS-KM");

    // Create and initialize QApplication object
    QApplication app(argc, argv);
    app.setApplicationDisplayName("CachyOS Keyboard Manager");
    app.setApplicationVersion("1.0.0");
    app.setQuitOnLastWindowClosed(true);

    // Check if another instance of the application is already running
    QSharedMemory sharedMemoryLock("CachyOS-KM-lock");
    if (sharedMemoryLock.attach())
    {
        QMessageBox::warning(nullptr, "CachyOS Keyboard Manager", "Another instance of the application is already running.");
        return -1;
    }

    if (!sharedMemoryLock.create(1))
    {
        QMessageBox::warning(nullptr, "CachyOS Keyboard Manager", "Failed to create shared memory lock.");
        return -1;
    }

    // Create and show the main window
    MainWindow w;
    w.show();

    // Run the application's event loop
    return app.exec();
}
