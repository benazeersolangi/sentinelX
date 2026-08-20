#!/bin/bash

echo "=========================================================="
echo "                 SentinelX v2.0"
echo "        Multi-Tool Security Assessment Framework"
echo "=========================================================="

echo ""
echo "Welcome to SentinelX"
echo ""
echo "1. Run All Scans"
echo "2. Nmap Scan"
echo "3. Nikto Web Scan"
echo "4. DNSRecon Scan"
echo "5. DNSEnum Scan"
echo "6. Exit"
echo ""

read -p "Choose an option: " option

if [ "$option" == "6" ]; then
    echo ""
    echo "Goodbye!"
    exit 0
fi

if [ "$option" != "1" ] && [ "$option" != "2" ] && \
   [ "$option" != "3" ] && [ "$option" != "4" ] && \
   [ "$option" != "5" ]; then

    echo ""
    echo "[!] Invalid option."
    exit 1
fi

echo ""
read -p "Enter Target IP or Domain: " target

if [ -z "$target" ]; then
    echo "[!] Target cannot be empty."
    exit 1
fi

mkdir -p output

echo ""
echo "[+] Target Selected: $target"
echo ""

# ==========================================================
# NMAP
# ==========================================================

if [ "$option" == "1" ] || [ "$option" == "2" ]; then

    echo "[+] Starting Nmap scan..."

    if [ -x "./modules/nmap.sh" ]; then
        ./modules/nmap.sh "$target" "output/nmap.txt"
    else
        nmap -sV "$target" -oN "output/nmap.txt"
    fi

    echo "[+] Nmap report saved: output/nmap.txt"
    echo ""

fi

# ==========================================================
# NIKTO
# ==========================================================

if [ "$option" == "1" ] || [ "$option" == "3" ]; then

    echo "[+] Starting Nikto scan..."

    nikto -h "$target" -output "output/nikto.txt"

    echo "[+] Nikto report saved: output/nikto.txt"
    echo ""

fi

# ==========================================================
# DNSRECON
# ==========================================================

if [ "$option" == "1" ] || [ "$option" == "4" ]; then

    echo "[+] Starting DNSRecon scan..."

    if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

        echo "[!] DNSRecon requires a domain name."
        echo "[!] Skipping DNSRecon for IP target."

    else

        dnsrecon -d "$target" -o "output/dnsrecon.txt"

        echo "[+] DNSRecon report saved: output/dnsrecon.txt"

    fi

    echo ""

fi

# ==========================================================
# DNSENUM
# ==========================================================

if [ "$option" == "1" ] || [ "$option" == "5" ]; then

    echo "[+] Starting DNSEnum scan..."

    if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

        echo "[!] DNSEnum requires a domain name."
        echo "[!] Skipping DNSEnum for IP target."

    else

        dnsenum "$target" > "output/dnsenum.txt"

        echo "[+] DNSEnum report saved: output/dnsenum.txt"

    fi

    echo ""

fi
# ==========================================================
# GEMINI AI REPORT GENERATION
# ==========================================================

echo "=========================================================="
echo "[+] Starting AI-powered report generation..."
echo "=========================================================="

if [ -z "$GEMINI_API_KEY" ]; then
    echo "[!] GEMINI_API_KEY is not configured."
    echo "[!] AI report generation skipped."
else

    echo "[+] Collecting scan results..."

    NMAP_RESULT=""
    NIKTO_RESULT=""
    DNSRECON_RESULT=""
    DNSENUM_RESULT=""

    [ -f "output/nmap.txt" ] && NMAP_RESULT=$(cat "output/nmap.txt")
    [ -f "output/nikto.txt" ] && NIKTO_RESULT=$(cat "output/nikto.txt")
    [ -f "output/dnsrecon.txt" ] && DNSRECON_RESULT=$(cat "output/dnsrecon.txt")
    [ -f "output/dnsenum.txt" ] && DNSENUM_RESULT=$(cat "output/dnsenum.txt")

    PROMPT=$(cat <<EOF
You are the senior cybersecurity analyst of SentinelX.

Analyze the following authorized security assessment results and create a highly professional, unique penetration-testing style report.

TARGET:
$target

================ NMAP ================
$NMAP_RESULT

================ NIKTO ================
$NIKTO_RESULT

================ DNSRECON ================
$DNSRECON_RESULT

================ DNSENUM ================
$DNSENUM_RESULT

REPORT REQUIREMENTS:

1. Executive Summary
2. Target Information
3. Assessment Methodology
4. Tools Used
5. Security Findings
6. Severity classification:
   Critical, High, Medium, Low, Informational
7. Evidence for every finding
8. Technical Analysis
9. Security Impact
10. Remediation Recommendations
11. Risk Summary
12. Overall Security Posture
13. Conclusion

IMPORTANT:

- Only report findings supported by the supplied scan results.
- Never invent vulnerabilities, ports, services or evidence.
- Do not claim exploitation was performed.
- Clearly distinguish actual findings from informational observations.
- Use professional cybersecurity terminology.
- Make the report suitable for a university cybersecurity project and professional client presentation.
- Make the HTML visually impressive and unique.
- Include SentinelX branding.
- Include professional tables, cards, severity badges and sections.
- Return ONLY valid HTML.
- Do NOT use Markdown code fences.
EOF
)

    echo "[+] Sending scan results to Gemini..."

    # Create JSON safely
    python3 - "$PROMPT" > output/gemini_request.json <<'PY'
import json
import sys

prompt = sys.argv[1]

request = {
    "model": "gemini-3.6-flash",
    "input": prompt
}

print(json.dumps(request))
PY

    # ======================================================
    # GEMINI INTERACTIONS API
    # ======================================================

    RESPONSE=$(curl -s \
        -X POST \
        "https://generativelanguage.googleapis.com/v1/interactions" \
        -H "x-goog-api-key: $GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        --data @output/gemini_request.json)

    echo "$RESPONSE" > output/gemini_response.json

    # Check API response
    if echo "$RESPONSE" | grep -q '"error"'; then

        echo "[!] Gemini API returned an error:"
        echo "$RESPONSE"

    else

        echo "[+] Gemini response received."

        REPORT=$(python3 - "$RESPONSE" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])

    # Current Interactions API response
    if "steps" in data:
        for step in reversed(data["steps"]):
            if step.get("type") == "model_output":
                for item in step.get("content", []):
                    if item.get("type") == "text":
                        print(item.get("text", ""))
                        raise SystemExit

    # Convenience/fallback format
    if "output_text" in data:
        print(data["output_text"])
        raise SystemExit

    print("")

except Exception:
    print("")
PY
)

        if [ -z "$REPORT" ]; then

            echo "[!] Gemini returned no report."
            echo "[!] Raw response saved to:"
            echo "    output/gemini_response.json"

        else

            # Remove accidental Markdown code fences
            REPORT=$(echo "$REPORT" | sed \
                -e 's/^```html//' \
                -e 's/^```//' \
                -e 's/```$//')

            echo "$REPORT" > output/SentinelX_Final_Report.html

            echo ""
            echo "=========================================================="
            echo "[+] AI REPORT GENERATED SUCCESSFULLY"
            echo "=========================================================="
            echo "[+] Report:"
            echo "    output/SentinelX_Final_Report.html"
            echo "=========================================================="

        fi

    fi

fi
