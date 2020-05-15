[Unit]
Description= TechTestApp Server 

[Service]
ExecStartPre= /etc/dist/TechTestApp
ExecStart= /etc/dist/TechTestApp serve

[Install]
WantedBy=multi-user.target 