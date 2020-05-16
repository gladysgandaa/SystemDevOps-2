[Unit]
Description=TechTestApp Server 

[Service]
Type=simple
User=root
WorkingDirectory=/etc/app/dist
ExecStart=/etc/app/dist/TechTestApp serve
Restart=on-failure

[Install]
WantedBy=multi-user.target 