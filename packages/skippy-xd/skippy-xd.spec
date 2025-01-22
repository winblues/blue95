Name:           skippy-xd
Version:        2024.12.26
Release:        1%{?dist}
Summary:        Fastfetch configuration for Universal Blue systems

URL:            https://github.com/felixfung/skippy-xd
Source:         https://github.com/felixfung/skippy-xd/archive/refs/tags/v2024.12.26.zip
License:        GPL-2.0

BuildRequires:  make
BuildRequires:  libXft-devel
BuildRequires:  libXrender-devel
BuildRequires:  libXcomposite-devel
BuildRequires:  libXdamage-devel
BuildRequires:  libXfixes-devel
BuildRequires:  libXext-devel
BuildRequires:  libXinerama-devel
BuildRequires:  libpng-devel
BuildRequires:  libjpeg-turbo-devel
BuildRequires:  giflib-devel

%description
Skippy-xd is a lightweight, window-manager-agnostic window selector on X server. With skippy, you get live-preview on your alt-tab motions; you get the much coveted expose feature from Mac; you get a handy overview of all your virtual desktops in one glance with paging mode.

%prep
%autosetup -n %{name}-%{version}

%build
make

%install
make DESTDIR=%{buildroot} install

%files
%{_bindir}/skippy-xd
%{_sysconfdir}/xdg/skippy-xd.rc

%changelog
%autochangelog
