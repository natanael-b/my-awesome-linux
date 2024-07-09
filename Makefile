install:
	mkdir -p /usr/local/share/applications/
	mkdir -p /opt/my-awesome-linux/
	cp -rf ./launchers/* /opt/my-awesome-linux/
	cp -rf ./scripts/* /usr/local/share/applications/

remove:
	rm -rf /opt/my-awesome-linux/
	rm /usr/local/share/applications/url.desktop
	rm /usr/local/share/applications/wine-intercept.desktop

