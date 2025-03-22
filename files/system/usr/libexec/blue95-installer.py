#!/usr/bin/python3

import gi
import gc
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, Pango
import os
import subprocess
import time
import json
from threading import Thread
import crypt
import shutil
import re

from pathlib import Path
import logging

def setup_logger():
    logger = logging.getLogger('blue95')
    logger.setLevel(logging.DEBUG)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG)

    file_handler = logging.FileHandler(os.path.expanduser("~/blue95-installer.log"))
    file_handler.setLevel(logging.DEBUG)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(formatter)
    file_handler.setFormatter(formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger

logger = setup_logger()

class BootcInstaller:
    STEP_NAMES = [
        ("WIPE", "Wiping drive"),
        ("PART", "Partitioning drive"),
        ("FS", "Creating filesystems"),
        ("FETCH", "Fetching layers"),
        ("DEPLOY", "Deploying image"),
        ("BOOTLOAD", "Installing bootloader"),
        ("FINAL", "Finalizing")
    ]

    def __init__(self):
        self.fs_type = "btrfs"
        self.target_disk = ""
        self.log_file = os.path.expanduser("~/bootc-install.log")
        self.raw_log_file = os.path.expanduser("~/bootc-install.log.ansi")

    def get_block_devices(self):
        result = subprocess.run(['lsblk', '-o', 'NAME,SIZE,TYPE', '-J'], capture_output=True, text=True)
        block_devices = json.loads(result.stdout)
        logger.debug("Block devices")
        logger.debug(block_devices)
        return block_devices['blockdevices']

    def current_step(self):
        last_step = "WIPE"
        with open(self.log_file, "r") as log_file:
            for line in log_file.readlines():
                if line.startswith("Checking that no-one is using this disk"):
                    last_step = "PART"
                elif line.startswith("Creating root filesystem"):
                    last_step = "FS"
                elif line.startswith("layers already present"):
                    last_step = "FETCH"

        return next(i for i, (key, _) in enumerate(self.STEP_NAMES) if key == last_step)

    def install(self):
        # TODO: remove when no longer needed
        # Fix up /var/tmp
        logger.info("Work around for /var/tmp")
        try:
            subprocess.run(["pkexec", "rm", "-rf", "/var/tmp"], check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            subprocess.run(["pkexec", "ln", "-s", "/tmp", "/var/tmp"], check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e.cmd}\nReturn code: {e.returncode}\nError: {e.stderr}")

        # bootc install
        logger.info(f"Calling bootc install to-disk {self.target_disk}")
        with open(self.log_file, "w") as log_file:
            process = subprocess.Popen(
                ["script", "-q", "-c", f"pkexec bootc install to-disk {self.target_disk} --wipe --source-imgref containers-storage:ghcr.io/winblues/blue95:latest", self.raw_log_file],
                stdout=log_file,
                stderr=subprocess.STDOUT,
                text=True
            )
            return process

    def post_install(self):
        root_partition = f"{self.target_disk}p3" if self.target_disk[-1].isdigit() else f"{self.target_disk}3"
        logger.info(f"Mounting {root_partition} to /mnt")
        try:
            subprocess.run(["pkexec", "mount", root_partition, "/mnt"], check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e.cmd}\nReturn code: {e.returncode}\nError: {e.stderr}")

        # Find installed system root
        candidate_roots = list(Path("/mnt/ostree/boot.1/default/").glob("*/"))
        assert len(candidate_roots) != 0, "Could not find installed root"
        installed_root = str(candidate_roots[0] / "0")

        # Set user and password
        username="cory"
        password="topanga"

        logger.info(f"Setting up user {username}")
        hashed_password = crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512))

        try:
            subprocess.run(["pkexec", "chroot", installed_root, "/usr/sbin/useradd", "-m", "-d", f"/var/home/{username}", "-G", "wheel", "-s", "/bin/bash", username], check=True)
            subprocess.run(["pkexec", "chroot", installed_root, "/usr/sbin/chpasswd", "-e"], input=f"{username}:{hashed_password}\n", text=True, check=True)
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e.cmd}\nReturn code: {e.returncode}\nError: {e.stderr}")


class Config:
  def __init__(self):
    running_folder = os.path.dirname(os.path.abspath(__file__))
    self.glade_file = Path.cwd() / "installer.glade"

    if not self.glade_file.exists():
      self.glade_file = "/usr/share/winblues/installer.glade"


class InstallGUI:
    def __init__(self):
        self.bootc_installer = BootcInstaller()
        self.config = Config()

        self.set_style()
        self.builder = Gtk.Builder()
        self.builder.add_from_file(str(self.config.glade_file))
        self.builder.connect_signals(self)

        treeview = self.builder.get_object("disks_treeview")
        selection = treeview.get_selection()
        selection.connect("changed", self.on_disk_selection_changed)

        # Window setup
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
        logger.info("Closing Window")
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
        # TODO: add user stuff here
            next_button.set_label("Install")
        #else:
        #    component_page = stack.get_child_by_name('page_customizations')
        #    next_button.set_label("Install")

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

    def on_disk_selection_changed(self, selection):
        model, treeiter = selection.get_selected()
        if treeiter is not None:
            disk_name = model[treeiter][0]
            logger.info(f"Selected disk: {disk_name}")
            self.bootc_installer.target_disk = f"/dev/{disk_name}"

    def show_disks(self):
        disks = self.bootc_installer.get_block_devices()
        treeview = self.builder.get_object('disks_treeview')
        liststore = Gtk.ListStore(str, str, str)

        for disk in disks:
            liststore.append([disk['name'], disk['size'], disk['type']])

        treeview.set_model(liststore)

    def install_blue95(self):

        self.progres_label_names = iter(BootcInstaller.STEP_NAMES)
        self.window_installer.hide()
        self.progress_bar = self.builder.get_object('progress bar')
        self.progress_label = self.builder.get_object('progress file')
        self.progress_label_component = self.builder.get_object('progress label')
        self.progress_label_component.set_label("{}".format(next(self.progres_label_names)))
        self.progress_label.set_label("...")
        self.progress_label.set_line_wrap(True)  # Enable wrapping
        self.progress_label.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR)  # Wrap at words & characters
        self.progress_label.set_max_width_chars(50)  # Optional: Limit width for readability
        self.progress_label.set_ellipsize(Pango.EllipsizeMode.NONE)  # Prevent truncation
        self.progress_bar.set_fraction(0.0)
        frac = 1.0 / 190
        self.progress_window.show_all()
        self.task = self.install()
        self.id = GLib.idle_add(self.task.__next__)

    def install(self):
        def update_progress_label():
            while True:
                if Path(self.bootc_installer.raw_log_file).exists():
                    with open(self.bootc_installer.log_file, "rb") as log_file:
                        raw_data = log_file.read()
                        decoded_text = raw_data.decode("utf-8", errors="replace")
                        lines = decoded_text.split("\n")
                        if len(lines) > 1:
                            last_line = lines[-1].strip()
                            GLib.idle_add(
                                self.progress_label.set_markup,
                                f'<span font_desc="CaskaydiaMono Nerd Font 13">{last_line}</span>'
                            )
                time.sleep(0.2)

        process = self.bootc_installer.install()

        Thread(target=update_progress_label, daemon=True).start()
        total_installation_steps = len(BootcInstaller.STEP_NAMES) + 1

        while True:
            step = self.bootc_installer.current_step()
            if process.poll() is not None:
                break

            self.progress_label_component.set_label(BootcInstaller.STEP_NAMES[step][1])
            self.progress_bar.set_fraction(float(step) / total_installation_steps)
            yield True
            time.sleep(0.1)

        self.progress_label_component.set_label("Post install")
        self.progress_bar.set_fraction(float(len(BootcInstaller.STEP_NAMES)) / total_installation_steps)
        self.bootc_installer.post_install()

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

    def cancel_install(self, button):
        logger.info("Cancelling Install")
        Gtk.main_quit()
        return False

app = InstallGUI()
Gtk.main()
