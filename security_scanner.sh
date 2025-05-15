#!/bin/bash

LOGFILE="/var/log/security_compliance_scanner.log"
sudo touch "$LOGFILE"
sudo chmod 666 "$LOGFILE"


show_output() {
    output="$1"
    dialog --backtitle "Security Compliance Scanner" --title "Result" --msgbox "$output" 20 80
}

show_output_file() {
    tempfile=$(mktemp)
    echo "$1" > "$tempfile"
    dialog --backtitle "Security Compliance Scanner" --title "Result" --textbox "$tempfile" 20 80
    rm -f "$tempfile"
}


open_ports_check() {
    result=$(sudo ss -tuln)
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

unowned_files_check() {
    result=$(sudo find / -nouser -o -nogroup 2>/dev/null)
    if [[ -z "$result" ]]; then
        result="No unowned files found."
    fi
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

weak_passwords_check() {
    result=$(sudo awk -F: '($2==""){print $1 " has no password set!"}' /etc/shadow)
    if [[ -z "$result" ]]; then
        result="No accounts with empty passwords."
    fi
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

file_permissions_check() {
    result=$(sudo find /etc -type f \( -perm -o+w -o -perm -g+w \) 2>/dev/null)
    if [[ -z "$result" ]]; then
        result="No insecure file permissions found."
    fi
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

firewall_status_check() {
    result=$(sudo ufw status)
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

password_policy_check() {
    result=$(sudo chage -l root)
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

apparmor_status_check() {
    result=$(sudo apparmor_status)
    echo "$result" | tee -a "$LOGFILE"
    show_output_file "$result"
}

view_full_report() {
    if [[ ! -s "$LOGFILE" ]]; then
        dialog --backtitle "Security Compliance Scanner" --title "Report" --msgbox "No scans have been run yet. The report is empty." 10 50
    else
        dialog --backtitle "Security Compliance Scanner" --title "Scan Report" --textbox "$LOGFILE" 25 80
    fi
}

security_scan_menu() {
    while true; do
        choice=$(dialog --clear --backtitle "Security Compliance Scanner" \
            --title "Security Scan Menu" \
            --menu "Select a check to run:" 20 60 10 \
1 "Check Open Ports" \
2 "Check Unowned Files" \
3 "Check Weak User Passwords" \
4 "Check Insecure File Permissions" \
5 "Check Firewall Status" \
6 "Check Password Policy (root)" \
7 "Check AppArmor Status" \
8 "Back to Main Menu" \
3>&1 1>&2 2>&3)

        [[ $? -ne 0 ]] && break

        case $choice in
            1) open_ports_check ;;
            2) unowned_files_check ;;
            3) weak_passwords_check ;;
            4) file_permissions_check ;;
            5) firewall_status_check ;;
            6) password_policy_check ;;
            7) apparmor_status_check ;;
            8) break ;;
        esac
    done
}

main_menu() {
    while true; do
        choice=$(dialog --clear --backtitle "Security Compliance Scanner" \
            --title "Main Menu" \
            --menu "Choose an option:" 20 60 10 \
1 "Run Security Scans" \
2 "View Full Report" \
3 "Exit" \
3>&1 1>&2 2>&3)

        [[ $? -ne 0 ]] && break

        case $choice in
            1) security_scan_menu ;;
            2) view_full_report ;;
            3) clear; exit ;;
        esac
    done
}

main_menu
