     *----------------------------------------------------------------
     * Begin P.GETCLIEN - Prototypes for GETCLIENT
     *
     *   12/15/09  DAS  6.10
     *     - Created
610aA*   01/05/10  MLB  6.10a
     *     - Enh: Corrected spelling on pLocationId variable.
740aA*   03/06/20  DAS  7.40a
     *     - Enh: Added optional parameter pClientInit.
     *     - Enh: Added optional parameter pHostSys
     *            Id's are in QCOPYSRC/HOSTSYSTEM
     *
     *----------------------------------------------------------------

     D getClient       pr                  extpgm('GETCLIENT')
     D  pClientId                    10
610aMD  pLocationId                  10
740aAD  pClientInit                   3    options(*nopass)
740aAD  pHostSys                     10    options(*nopass)

     *** End P.GETCLIEN ***
