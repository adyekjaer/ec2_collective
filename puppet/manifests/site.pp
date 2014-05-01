node default {
    if !$nodeclass {
        notify {'nodeclass not defined!' :}
    } else {
        notify {"Applying class $nodeclass":}
        include $nodeclass
    }
}
