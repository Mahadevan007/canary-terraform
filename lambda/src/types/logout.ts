
export interface RemoveCommandResponse {
    "jsonrpc":string;
    "result":string;
    "id":string
}

export interface ShowCommandResult {
    "jsonrpc": string,
    "result": {
        "Domains": [
            {
                "name": string,
                "hash_size": number,
                "AORs": AORDetails[]
            }
        ]
    },
    "id": "11"
}

export interface AORDetails {
    "AOR": string,
    "Contacts": AORContact[]
}

export interface AORContact {
    "Contact": string,
    "ContactID": string,
    "Expires": number,
    "Q": string,
    "Callid": string,
    "Cseq": number,
    "User-agent": string,
    "State": string,
    "Flags": number,
    "Cflags": string,
    "Methods": number
}