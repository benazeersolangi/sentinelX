# SentinelX v2.0

## Multi-Tool Security Assessment Framework with AI-Powered Reporting

SentinelX is a Bash-based cybersecurity assessment framework that combines multiple security reconnaissance and web assessment tools into a single automated workflow.

The project integrates:

- Nmap
- Nikto
- DNSRecon
- DNSEnum
- Gemini AI
- Automated HTML report generation

The main purpose of SentinelX is to collect security assessment results from multiple tools, combine their outputs, and use Gemini AI to transform the results into a professional, structured security assessment report.

---

## Project Objective

The objective of SentinelX is to simplify the initial security assessment and reporting process by bringing multiple command-line security tools into one framework.

Instead of manually checking every tool's output and preparing a report separately, SentinelX:

1. Accepts an IP address or domain as the target.
2. Runs the selected security assessment modules.
3. Saves raw scan results in the `output/` directory.
4. Sends the collected results to Gemini AI.
5. Uses AI to analyze the supplied evidence.
6. Generates a professional HTML security assessment report.

---

## Features

### 1. Run All Scans

The user can select **Run All Scans** to execute the available SentinelX modules automatically.

### 2. Nmap Integration

Nmap is used for network discovery, port scanning, service detection, and version detection.

Example output:

```text
output/nmap.txt
```

### 3. Nikto Integration

Nikto is used for web-server security assessment and identification of potentially interesting server-side issues.

Example output:

```text
output/nikto.txt
```

### 4. DNSRecon Integration

DNSRecon is used for DNS reconnaissance and domain-related information gathering.

Example output:

```text
output/dnsrecon.txt
```

DNSRecon is skipped automatically when the supplied target is an IP address because the module requires a domain name.

### 5. DNSEnum Integration

DNSEnum is used for DNS enumeration and related domain reconnaissance.

Example output:

```text
output/dnsenum.txt
```

DNSEnum is also skipped automatically for IP-only targets.

### 6. Gemini AI Integration

SentinelX uses the Gemini API to analyze the collected scan results.

The AI is instructed to:

- Analyze only the supplied scan evidence.
- Avoid inventing vulnerabilities.
- Identify and classify findings.
- Assign severity levels.
- Explain technical impact.
- Provide remediation recommendations.
- Produce a professional security assessment report.

The current Gemini documentation recommends the Interactions API for new Gemini API integrations. SentinelX can use the REST Interactions endpoint with the `GEMINI_API_KEY` environment variable. 

### 7. Automated HTML Report

After the scan results are analyzed, SentinelX saves the AI-generated report as:

```text
output/SentinelX_Final_Report.html
```

The report is intended to contain:

- Executive Summary
- Target Information
- Assessment Methodology
- Tools Used
- Security Findings
- Severity Classification
- Evidence
- Technical Analysis
- Security Impact
- Recommendations
- Risk Summary
- Overall Security Posture
- Conclusion

---

## Menu

When SentinelX starts, it provides the following options:

```text
1. Run All Scans
2. Nmap Scan
3. Nikto Web Scan
4. DNSRecon Scan
5. DNSEnum Scan
6. Exit
```

---

## Project Structure

```text
SentinelX/
│
├── sentinelx.sh
│
├── modules/
│   ├── nmap.sh
│   └── nmap.txt
│
└── output/
    ├── nmap.txt
    ├── nikto.txt
    ├── dnsrecon.txt
    ├── dnsenum.txt
    ├── gemini_response.json
    └── SentinelX_Final_Report.html
```

The exact files inside `output/` depend on which modules are executed and whether AI report generation succeeds.

---

## Requirements

SentinelX is designed for Kali Linux or another Linux environment containing the required tools.

Required components:

- Bash
- Nmap
- Nikto
- DNSRecon
- DNSEnum
- curl
- Python 3
- Gemini API key

Check the tools with:

```bash
which bash
which nmap
which nikto
which dnsrecon
which dnsenum
which curl
which python3
```

---

## Gemini API Configuration

Do **not** hard-code your API key inside `sentinelx.sh`.

Google's Gemini documentation recommends configuring the API key through an environment variable:

```bash
export GEMINI_API_KEY="YOUR_API_KEY"
```

For persistent configuration on Kali Linux, the variable can be added to the user's shell configuration and loaded with:

```bash
source ~/.bashrc
```

Keep API keys private and never commit them to GitHub or include them in screenshots or project files.

---

## Installation

Clone or copy the SentinelX project into your desired directory.

Example:

```bash
cd ~/Desktop
cd sentinelX
```

Make the main script executable:

```bash
chmod +x sentinelx.sh
```

If the Nmap module is executable:

```bash
chmod +x modules/nmap.sh
```

Set the Gemini API key:

```bash
export GEMINI_API_KEY="YOUR_API_KEY"
```

---

## Running SentinelX

Start the framework:

```bash
./sentinelx.sh
```

or:

```bash
bash sentinelx.sh
```

Select:

```text
1
```

for the complete assessment.

Then enter an authorized target:

```text
Enter Target IP or Domain:
```

---

## Automated AI Workflow

The complete workflow is:

```text
                 SentinelX
                     |
          Target IP / Domain
                     |
        +------------+------------+
        |            |            |
       Nmap        Nikto       DNS Tools
        |            |          /      \
        |            |     DNSRecon   DNSEnum
        +------------+------------+
                     |
              Raw Scan Results
                     |
               output/*.txt
                     |
                     v
                Gemini AI
                     |
          Security Analysis
                     |
        +------------+-------------+
        |            |             |
     Findings     Severity     Recommendations
        |            |             |
        +------------+-------------+
                     |
                     v
        SentinelX_Final_Report.html
```

---

## AI Reporting Logic

SentinelX sends the collected scan results to Gemini with instructions to generate a security assessment.

The AI is expected to distinguish between:

### Confirmed Findings

Issues directly supported by the supplied scanner evidence.

### Informational Observations

Useful security information that does not necessarily represent a vulnerability.

### Severity

Findings can be categorized as:

- Critical
- High
- Medium
- Low
- Informational

The AI should not claim exploitation unless the supplied evidence explicitly demonstrates that exploitation occurred.

---

## Report Design

The generated HTML report is intended to be more than a raw scanner-output dump.

It should transform technical output into a structured assessment containing:

```text
SentinelX Security Assessment
│
├── Executive Summary
├── Target Information
├── Methodology
├── Tools Used
├── Risk Overview
├── Findings
│   ├── Severity
│   ├── Evidence
│   ├── Technical Analysis
│   ├── Impact
│   └── Recommendation
├── Overall Security Posture
└── Conclusion
```

---

## Security and Responsible Use

SentinelX should only be used against systems that you own or have explicit authorization to assess.

Do not use the framework to scan unauthorized systems.

API keys must be protected. If an API key is accidentally exposed, revoke it and create a replacement key.

---

## Troubleshooting

### API key not detected

If the script reports:

```text
[!] GEMINI_API_KEY is not configured.
```

set the variable:

```bash
export GEMINI_API_KEY="YOUR_API_KEY"
```

Then run SentinelX again.

### Check the API key variable

```bash
echo "$GEMINI_API_KEY"
```

Do not share the output publicly.

### HTML report not generated

Check whether the raw reports exist:

```bash
ls -lh output/
```

Then inspect the Gemini response:

```bash
cat output/gemini_response.json
```

### Tool not found

For example:

```text
nmap: command not found
```

Check:

```bash
which nmap
```

Repeat for:

```bash
which nikto
which dnsrecon
which dnsenum
```

---

## Example Final Output

After a successful complete run:

```text
output/
├── nmap.txt
├── nikto.txt
├── dnsrecon.txt
├── dnsenum.txt
├── gemini_response.json
└── SentinelX_Final_Report.html
```

Open the final report in a browser:

```bash
firefox output/SentinelX_Final_Report.html
```

---

## Advantages of SentinelX

- Multiple security tools in one framework
- Simple menu-driven Bash interface
- Automated output collection
- DNS-aware target handling
- AI-assisted security analysis
- Severity classification
- Evidence-based findings
- Automated recommendations
- Professional HTML reporting
- Reduces manual report-writing effort

---

## Future Enhancements

Possible future improvements include:

- PDF report generation
- CVSS-based risk scoring
- Interactive charts and dashboards
- Scan timestamp and assessment metadata
- Custom report templates
- Report comparison between scans
- Additional authorized security modules
- Better HTML styling and responsive design
- Export to JSON
- Automated report archiving

---

## Disclaimer

SentinelX is an educational and authorized security-assessment framework. The project is intended for cybersecurity learning, laboratory environments, and systems for which the user has explicit permission to perform security testing.

The AI-generated report should be reviewed by a human security professional before being treated as a final security assessment.

---

## Author

**SentinelX v2.0**

Multi-Tool Security Assessment Framework

Built with:

- Bash
- Nmap
- Nikto
- DNSRecon
- DNSEnum
- Gemini AI
- HTML/CSS
