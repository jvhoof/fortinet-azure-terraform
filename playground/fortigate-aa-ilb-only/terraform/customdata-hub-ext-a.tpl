Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config sys global
    set admintimeout 120
    set hostname "${fgt_hub_a_vm_name}"
    set timezone 26
    set admin-sport 8443
    set admin-ssh-port 8442
    set gui-theme mariner
end
config vpn ssl settings
    set port 7443
end
config router static
    edit 1
        set gateway ${fgt_hub_a_external_gw}
        set device port1
    next
    edit 2
        set dst ${hub_vnet_network}
        set gateway ${fgt_hub_a_internal_gw}
        set device port2
    next
    edit 3
        set dst ${spoke1_vnet_network}
        set gateway ${fgt_hub_a_internal_gw}
        set device port2
    next
    edit 4
        set dst ${spoke2_vnet_network}
        set gateway ${fgt_hub_a_internal_gw}
        set device port2
    next 
    edit 5
        set dst 168.63.129.16 255.255.255.255
        set device port2
        set gateway ${fgt_hub_a_internal_gw}
    next
    edit 6
        set dst 168.63.129.16 255.255.255.255
        set device port1
        set gateway ${fgt_hub_a_external_gw}
    next
end
config system probe-response
    set http-probe-value OK
    set mode http-probe
end
config system interface
    edit port1
        set mode static
        set ip ${fgt_hub_a_external_ipaddr}/${fgt_hub_a_external_mask}
        set description external
        set allowaccess ping fgfm probe-response
    next
    edit port2
        set mode static
        set ip ${fgt_hub_a_internal_ipaddr}/${fgt_hub_a_internal_mask}
        set description internal
        set allowaccess ping probe-response
    next
    edit port3
        set mode static
        set ip ${fgt_hub_a_hasync_ipaddr}/${fgt_hub_a_hasync_mask}
        set description hasync
        set allowaccess ping
    next
    edit port4
        set mode static
        set ip ${fgt_hub_a_mgmt_ipaddr}/${fgt_hub_a_mgmt_mask}
        set description mgmt
        set allowaccess ping https ssh
    next
end
config system ha
    set group-name AzureHA
    set mode a-p
    set hbdev port3 100
    set session-pickup enable
    set session-pickup-connectionless enable
    set ha-mgmt-status enable
    config ha-mgmt-interfaces
        edit 1
            set interface port4
            set gateway ${fgt_hub_a_mgmt_gw}
        next
    end
    set override enable
    set priority 200
    set unicast-hb enable
    set unicast-hb-peerip ${fgt_hub_a_ha_peerip}
end
config firewall policy
    edit 1
        set name "OUTBOUND"
        set srcintf "port2"
        set dstintf "port1"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
end
%{ if fgt_hub_a_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fgt_hub_a_license_file}"

${file(fgt_hub_a_license_file)}

%{ endif }
--===============0086047718136476635==--