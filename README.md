# Locket
Toolkit to create EVM compatible private keys, following high grade security practices.

## Key Security Principles

1. **Offline-First**
   - All private keys are generated on an **air-gapped machine** (no network access).
   - Prevents remote attackers or malware from intercepting entropy or key material.

2. **RAM-Mounted Filesystem**
   - Temporary files are handled in a `tmpfs` (RAM-only filesystem).
   - Ensures no sensitive artifacts are ever written to persistent disk.
   - Eliminates forensic recovery from deleted files on SSDs/HDDs.

3. **Strong Symmetric Encryption**
   - Keys are wrapped with **GnuPG AES-256** before leaving the offline machine.
   - Exported key exists only as `private.gpg`, never in plaintext.
   - Encrypted artifacts are safe for storage on disk or in the cloud.

4. **High-Entropy Human Passphrase**
   - Encryption passphrase generated via **Diceware 13-word method** (~167 bits of entropy).
   - Balances memorability with cryptographic strength.
   - Resistant to brute-force attacks even with nation-state resources.

5. **Manual Passphrase Custody**
   - Passphrase is physically written down on paper/metal.
   - No cloud sync, no password manager, no plaintext storage.
   - Removes supply-chain or sync compromise risks.

 ## Threat Models Mitigated

- **Remote Attacks**: No network during key generation.  
- **Disk Forensics**: Key never touches disk in raw form.  
- **Cloud Leaks**: Only encrypted files ever uploaded.  
- **Brute Force**: Diceware passphrase is computationally infeasible to crack.  
- **Lost Devices**: Physical theft of backup is useless without passphrase.