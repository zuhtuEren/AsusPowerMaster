show_dashboard() {
    local BLUE='\033[0;34m'; local YELLOW='\033[1;33m'; local GREEN='\033[0;32m'; local NC='\033[0m'
    
    # Verileri topla
    local cap=$(cat "$BAT_DIR/capacity" 2>/dev/null || echo "N/A")
    local threshold=$(cat "$BAT_DIR/charge_control_end_threshold" 2>/dev/null || echo "N/A")
    local temp=$(($(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000))
    local watt=$(get_wattage)
    local kbd_level=$(cat "$KBD_PATH/brightness" 2>/dev/null || echo "N/A")
    local status=$(get_ac_status)
    
    # Fan Durumu
    case $(cat "$FAN_PATH" 2>/dev/null) in
        0) fan_status="Balanced" ;; 1) fan_status="Overboost" ;; 2) fan_status="Silent" ;; *) fan_status="N/A" ;;
    esac

    # Profil Kontrolü
    local profile="Default"
    [ -f "/etc/asus-power.conf" ] && profile="Custom (User Defined)"

    echo -e "\n${BLUE}      ASUS POWER MASTER v2.6 STATUS${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo -e "  ${YELLOW}Active Profile:${NC}    $profile"
    echo -e "  ${YELLOW}Power Source:${NC}      $( [[ "$status" == "1" ]] && echo "AC Adapter" || echo "Battery" )"
    echo -e "  ${YELLOW}Battery Level:${NC}     $cap% (Limit: $threshold%)"
    echo -e "  ${YELLOW}Fan Mode:${NC}          $fan_status"
    echo -e "  ${YELLOW}Power Draw:${NC}        ${GREEN}${watt} Watts${NC}"
    echo -e "  ${YELLOW}CPU Temp:${NC}          $temp°C"
    echo -e "  ${YELLOW}Kbd Light:${NC}         Level $kbd_level"
    echo -e "${BLUE}=======================================${NC}\n"
}
