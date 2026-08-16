# --- bridge ---

import {
  to = module.interfaces.routeros_interface_bridge.bridge
  id = "name=bridge"
}


# --- ethernets ---

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["ether1"]
  id = "name=ether1"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["ether2"]
  id = "name=ether2"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["ether3"]
  id = "name=ether3"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["ether4"]
  id = "name=ether4"
}

import {
  to = module.interfaces.routeros_interface_ethernet.interfaces["ether5"]
  id = "name=ether5"
}


# --- bonds ---

import {
  to = module.interfaces.routeros_interface_bonding.bonds["eth[4-5]"]
  id = "name=eth[4-5]"
}


# --- bridge ports ---

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["ether2"]
  id = "interface=ether2"
}

import {
  to = module.interfaces.routeros_interface_bridge_port.interfaces["ether3"]
  id = "interface=ether3"
}

#import {
#  to = module.interfaces.routeros_interface_bridge_port.interfaces["ether4"]
#  id = "interface=ether4"
#}
#
#import {
#  to = module.interfaces.routeros_interface_bridge_port.interfaces["ether5"]
#  id = "interface=ether5"
#}

import {
  to = module.interfaces.routeros_interface_bridge_port.bonds["eth[4-5]"]
  id = "interface=eth[4-5]"
}


# --- bridge (l2) vlans ---

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["mgmt"]
  id = "comment=mgmt"
}

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["home"]
  id = "comment=home"
}

import {
  to = module.interfaces.routeros_interface_bridge_vlan.vlans["guest"]
  id = "comment=guest"
}


# --- interface (l3) vlans / svis ---

import {
  to = module.interfaces.routeros_interface_vlan.svi_vlans["mgmt"]
  id = "name=mgmt"
}

import {
  to = module.interfaces.routeros_ip_address.svi_vlans["mgmt"]
  id = "interface=mgmt"
}

import {
  to = module.interfaces.routeros_interface_vlan.svi_vlans["home"]
  id = "name=home"
}

import {
  to = module.interfaces.routeros_ip_address.svi_vlans["home"]
  id = "interface=home"
}

import {
  to = module.interfaces.routeros_interface_vlan.svi_vlans["guest"]
  id = "name=guest"
}

import {
  to = module.interfaces.routeros_ip_address.svi_vlans["guest"]
  id = "interface=guest"
}
