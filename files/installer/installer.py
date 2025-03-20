#!/usr/bin/python3

import gi
import gc
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib
import os
import subprocess
import time

from pathlib import Path
import shutil


class Config:
  def __init__(self):
    running_folder = os.path.dirname(os.path.abspath(__file__))
    self.glade_file = Path(running_folder) / "installer.glade"

    if not self.glade_file.exists():
      self.glade_file = "/usr/share/winblues/installer.glade"


config = Config()

class InstallGUI:
	def __init__(self):
		self.set_style()
		self.builder = Gtk.Builder()
		self.builder.add_from_file(str(config.glade_file))
		self.builder.connect_signals(self)
		self.set_options()
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
		Gtk.StyleContext.add_provider_for_screen( screen, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION )

	def on_window_destroy(self, window):
		print("Closing Window")
		Gtk.main_quit()
		return False

	def set_options(self):
		self.install_theme = True
		self.install_icons = True
		self.install_cursors = True
		self.install_background = True
		self.install_sounds = True
		self.install_fonts = True
		self.thunar = True
		self.terminal_colors = True
		self.bash = True
		self.zsh = False
		self.panel = True

	def next_clicked(self, button):
		stack = self.builder.get_object('stack')
		current_page = stack.get_visible_child_name()
		next_button = self.builder.get_object('next')
		if next_button.get_label() == "Install":
			self.install_chicago95()
			return
		
		if next_button.get_label() == "Finish":
			print("Install Completed! Enjoy Chicago95!")
			Gtk.main_quit()
			return False

		if current_page == 'page_welcome':
			#component_page = self.builder.get_object('page_components')
			component_page = stack.get_child_by_name('page_components')
			back_button = self.builder.get_object('back')
			back_button.set_sensitive(True)

			# Get the labels
			self.theme_size = self.builder.get_object('theme size')
			self.icons_size = self.builder.get_object('icons size')
			self.cursors_size = self.builder.get_object('cursors size')
			self.background_size = self.builder.get_object('background size')
			self.sounds_size = self.builder.get_object('sound size')
			self.fonts_size = self.builder.get_object('font size')
			self.remaining_size = self.builder.get_object('remaining size')
			self.total_size = self.builder.get_object('total size')
			# Change the labels
			self.theme_size.set_label("{} k".format(0))
			self.icons_size.set_label("{} k".format(0))
			self.cursors_size.set_label("{} k".format(0))
			self.sounds_size.set_label("{} k".format(0))
			self.fonts_size.set_label("{} k".format(0))
			self.remaining_size.set_label("{:.0f} k".format(int(0)))
			self.total_size.set_label("{} k".format(0))


		else:
			component_page = stack.get_child_by_name('page_customizations')
			thunar_check = self.builder.get_object('thunar')
			panel_check = self.builder.get_object('panel')
			if not self.install_theme:
				print('[THUNAR] Warning: GTK Theme not selected, cannot install Thunar status bar image')
				thunar_check.set_tooltip_text("Warning: GTK Theme not selected, cannot install Thunar status bar image")
				thunar_check.set_sensitive(False)
				thunar_check.set_active(False)
				self.thunar = False
			else:
				thunar_check.set_tooltip_text("Enables the Thunar status bar image")
				thunar_check.set_sensitive(True)
				thunar_check.set_active(True)
				self.thunar = True

				
			next_button.set_label("Install")
			
		stack.set_visible_child(component_page)

	def back_clicked(self, button):
		stack = self.builder.get_object('stack')
		current_page = stack.get_visible_child_name()

		if current_page == 'page_components':
			#component_page = self.builder.get_object('page_components')
			component_page = stack.get_child_by_name('page_welcome')
			back_button = self.builder.get_object('back')
			back_button.set_sensitive(False)

		else:
			component_page = stack.get_child_by_name('page_components')
			next_button = self.builder.get_object('next')
			next_button.set_label("Next")
			
		stack.set_visible_child(component_page)

	def install_chicago95(self):
		components = "\tTheme:\t\t{}\n\tIcons:\t\t{}\n\tCursors:\t{}\n\tBackground:\t{}\n\tSounds:\t\t{}\n\tFonts:\t\t{}".format(self.install_theme, self.install_icons, self.install_cursors, self.install_background, self.install_sounds, self.install_fonts)
		customizations = "\tThunar Graphics:\t{}\n\tChange Terminal Colors:\t{}\n\tSet Bash Prompt:\t{}\n\tSet zsh promt/theme:\t{}\n\tCustomize Panel:\t{}".format(self.thunar, self.terminal_colors, self.bash, self.zsh, self.panel)
		self.progress_label_sections = []
		print("Installing Chicago 95 with the following options:\n Components:\n {}\n Customizations:\n {}".format(components, customizations))
		self.copy_files = {}

		self.progres_label_names = iter(self.progress_label_sections)
		self.window_installer.hide()
		self.progress_bar = self.builder.get_object('progress bar')
		self.progress_label = self.builder.get_object('progress file')
		self.progress_label_component = self.builder.get_object('progress label')
		self.progress_label_component.set_label("Installing component: {}".format(next(self.progres_label_names)))
		first_file_name = list(self.copy_files.keys())[0].split("/")[-1]
		self.progress_label.set_label(first_file_name)
		self.progress_bar.set_fraction(0.0)
		frac = 1.0 / len(self.copy_files)
		self.progress_window.show_all()
		self.task = self.install()
		self.id = GLib.idle_add(self.task.__next__)

		
	def install(self):
		i = 0.0
		print("Installing Chicago 95")

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
