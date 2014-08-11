package com.latham.group.model;

import org.jivesoftware.smack.XMPPException;

public interface Chat {
    void sendMessage(String message) throws XMPPException;

    void release() throws XMPPException;
}
