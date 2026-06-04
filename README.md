```
    ██████╗  █████╗ ██████╗ ██╗  ██╗████████╗███████╗██████╗ ███╗   ███╗
    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
    ██║  ██║███████║██████╔╝█████╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
    ██║  ██║██╔══██║██╔══██╗██╔═██╗    ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
    ██████╔╝██║  ██║██║  ██║██║  ██╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
```

<p align="center">
  <b>Advanced Ethical Hacking Framework for Termux</b><br>
  <i>Authorized Testing Only | Use Responsibly</i>
</p>

<p align="center">
  <a href="https://github.com/Anon4You/darkterm/stargazers"><img src="https://img.shields.io/github/stars/Anon4You/darkterm?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/Anon4You/darkterm/network/members"><img src="https://img.shields.io/github/forks/Anon4You/darkterm?style=flat-square" alt="Forks"></a>
  <a href="https://github.com/Anon4You/darkterm/issues"><img src="https://img.shields.io/github/issues/Anon4You/darkterm?style=flat-square" alt="Issues"></a>
  <a href="https://github.com/Anon4You/darkterm/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Anon4You/darkterm?style=flat-square" alt="License"></a>
</p>

---

> [!NOTE]
> This toolkit requires the **TermuxVoid** repository for security tools.
> Visit https://termuxvoid.github.io/ to add the repo to Termux.

## Installation

```bash
git clone https://github.com/Anon4You/darkterm.git
cd darkterm
chmod +x darkterm.sh
./darkterm.sh
```

Or create a global shortcut (run this from inside the cloned repo):

```bash
ln -sf "$PWD/darkterm.sh" $PREFIX/bin/darkterm
darkterm
```

## Modules

```
 [1]  Reconnaissance & OSINT           theHarvester, Amass, Subfinder, Whois,
                                        DNSx, DNSmap, Waybackurls, CeWL,
                                        HTTrack, Katana
 [2]  Network Scanning & Enumeration   Nmap, fscan, Netcat, HTTPing, gping,
                                        2ping, Traceroute, ARP Scan, Port Sweep
 [3]  Web Application Testing          Nikto, SQLmap, Nuclei, HTTPx, Gobuster,
                                        FFUF, Dirb, WAFw00f, WPScan
 [4]  Password Attacks & Cracking      John, Hashcat, Hydra, BruteSpray, CUPP,
                                        Hashid, PDFCracker, Kerbrute, OpenSSL
 [5]  Exploitation & Post-Exploitation Metasploit, SearchSploit, Netcat Shells,
                                        SSH Tunnels, ProxyChains
 [6]  Cryptography & Encoding          OpenSSL, Python Crypto, GPG, Base64,
                                        Hex, URL encode/decode, SSL Analyzer
 [7]  Forensics & Analysis             File Analysis, Hashdeep, APKLeaks,
                                        Log Analyzer, Process Monitor
 [8]  Utilities                        Wordlist Generator, Password Generator,
                                        IP Info, HTTP Headers, SSH Keys, Logs
 [9]  Quick Scans (Automated)           Full Recon, Web Audit, Network Map,
                                        Password Audit, SSL Audit
```

## Features

- **60+ integrated tools** across 9 modules
- **Auto-install** missing packages via `apt` when you try to use them
- **No root required** - runs entirely in userspace
- **Activity logging** to `logs/darkterm.log`
- **Loot storage** - all scan results saved to `loot/`
- **Interactive menus** with sub-options for each tool
- **Quick scans** - automated multi-tool pipelines

## Auto-Install

When you select a tool that isn't installed, darkterm will prompt:

```
[!] 'nmap' is not installed (package: nmap)
Install nmap now? [y/N]:
```

Type `y` and it installs via `apt` automatically, then continues.

## Directory Structure

```
darkterm/
├── darkterm.sh        # Main script
├── logs/              # Activity logs
├── loot/              # Scan results & output
├── wordlists/         # Generated wordlists
├── LICENSE
└── README.md
```

## Author

**Alienkrishn** \[Anon4You\]
- GitHub: [@Anon4You](https://github.com/Anon4You)

> [!CAUTION]
> This tool is provided for **authorized security testing and educational purposes only**. Unauthorized access to computer systems is illegal. Always obtain explicit written permission before testing. The author is not responsible for any misuse.

## License

[BSD 3-Clause](LICENSE)
