[Unit]
Description=TechTestApp Server 

[Service]
Type=simple
User=root
WorkingDirectory=/etc/dist/
ExecStart=/etc/dist/TechTestApp serve
Restart=on-failure

[Install]
WantedBy=multi-user.target 