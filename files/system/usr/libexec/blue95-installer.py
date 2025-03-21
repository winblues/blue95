#!/usr/bin/python3

import gi
import gc
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib
import os
import subprocess
import time
import json

from pathlib import Path
import shutil

class BootcInstaller:
    def __init__(self):
        self.fs_type = "btrfs"
        self.target_disk = "/dev/vda"

    def install(self):
        pass

class Config:
  def __init__(self):
    running_folder = os.path.dirname(os.path.abspath(__file__))
    self.glade_file = Path.cwd() / "installer.glade"

    if not self.glade_file.exists():
      self.glade_file = "/usr/share/winblues/installer.glade"

config = Config()

class InstallGUI:
    def __init__(self):
        self.bootc_installer = BootcInstaller()

        self.set_style()
        self.builder = Gtk.Builder()
        self.builder.add_from_file(str(config.glade_file))
        self.builder.connect_signals(self)
        window = self.builder.get_object('main window')
        self.window_installer = self.builder.get_object('installer')
        self.window_installer.connect('delete-event', lambda x,y: Gtk.main_quit())
        self.progress_window = self.builder.get_object('progress')
        self.progress_window.connect('delete-event', lambda x,y: Gtk.main_quit())
        window.show_all()
        self.window_installer.show_all()

    def set_style(self):
        # From https://gist.github.com/carlos-jenkins/8923124
        provider = Gtk.CssProvider()
        provider.load_from_path("/usr/src/chicago95/Theme/Chicago95/gtk-3.0/gtk.css")
        screen = Gdk.Display.get_default_screen(Gdk.Display.get_default())
        # I was unable to found instrospected version of this
        GTK_STYLE_PROVIDER_PRIORITY_APPLICATION = 600
        Gtk.StyleContext.add_provider_for_screen(screen, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)

    def on_window_destroy(self, window):
        print("Closing Window")
        Gtk.main_quit()
        return False

    def next_clicked(self, button):
        stack = self.builder.get_object('stack')
        current_page = stack.get_visible_child_name()
        next_button = self.builder.get_object('next')
        if next_button.get_label() == "Install":
            self.install_blue95()
            return

        if next_button.get_label() == "Finish":
            Gtk.main_quit()
            return False

        if current_page == 'page_welcome':
            component_page = stack.get_child_by_name('page_disks')
            self.show_disks()
            back_button = self.builder.get_object('back')
            back_button.set_sensitive(True)
        else:
            component_page = stack.get_child_by_name('page_customizations')
            next_button.set_label("Install")

        stack.set_visible_child(component_page)

    def back_clicked(self, button):
        stack = self.builder.get_object('stack')
        current_page = stack.get_visible_child_name()

        if current_page == 'page_disks':
            component_page = stack.get_child_by_name('page_welcome')
            back_button = self.builder.get_object('back')
            back_button.set_sensitive(False)
        else:
            component_page = stack.get_child_by_name('page_disks')
            next_button = self.builder.get_object('next')
            next_button.set_label("Next")

        stack.set_visible_child(component_page)

    def show_disks(self):
        # Retrieve the list of hard disks/block devices
        disks = self.get_block_devices()
        treeview = self.builder.get_object('disks_treeview')
        liststore = Gtk.ListStore(str, str, str)

        for disk in disks:
            liststore.append([disk['name'], disk['size'], disk['type']])

        treeview.set_model(liststore)

    def get_block_devices(self):
        # Use 'lsblk' command to get block devices
        result = subprocess.run(['lsblk', '-o', 'NAME,SIZE,TYPE', '-J'], capture_output=True, text=True)
        block_devices = json.loads(result.stdout)
        return block_devices['blockdevices']

    def install_blue95(self):
        self.progress_label_sections = ["Wiping drive", "Partitioning drive", "Creating filesystems", "Fetching layers", "Deploying image", "Installing bootloader", "Finalizing"]
        self.copy_files = {}

        self.progres_label_names = iter(self.progress_label_sections)
        self.window_installer.hide()
        self.progress_bar = self.builder.get_object('progress bar')
        self.progress_label = self.builder.get_object('progress file')
        self.progress_label_component = self.builder.get_object('progress label')
        self.progress_label_component.set_label("Installing component: {}".format(next(self.progres_label_names)))
        self.progress_label.set_label("foobar")
        self.progress_bar.set_fraction(0.0)
        frac = 1.0 / 190
        self.progress_window.show_all()
        self.task = self.install()
        self.id = GLib.idle_add(self.task.__next__)

    def install(self):
        stack = self.builder.get_object('stack')
        stack.set_visible_child(stack.get_child_by_name('page_completed'))
        self.progress_window.hide()
        next_button = self.builder.get_object('next')
        back_button = self.builder.get_object('back')
        back_button.set_sensitive(False)
        next_button.set_label("Finish")
        self.window_installer.show_all()
        GLib.source_remove(self.id)
        yield False

    def change_component_label(self):
        try:
            self.progress_label_component.set_label("Installing component: {}".format(next(self.progres_label_names)))
        except:
            pass

    def cancel_install(self, button):
        print("Cancelling Install")
        Gtk.main_quit()
        return False

app = InstallGUI()
Gtk.main()
