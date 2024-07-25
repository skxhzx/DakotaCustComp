     *----------------------------------------------------------------
     *
     *  OPTIONCDS  Redefinition data structures for OPTIONC file,
     *             customer options.
     *
     *  03 Dec 2014
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    12/03/14  RBD  6.50
     *      - Created.
     *
730aA*    03/08/19  RBD  7.30a
     *      - Added *TRAX options OPCSOR, OPCODE, OPCODP, OPCONT, OPCOTP
     *        and OPCNSB.
     *
730bA*    03/30/19  RBD  7.30b
     *      - Changed OPCODE to OPCODX ... OPCODE already used, duh.
     *        This same field in OPTIONS is OPTODE.
     *
     *----------------------------------------------------------------
     *  *TRAX  -  TRAX customer options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCCWR  -  Catch weight required
     *    OPCBDA  -  Breakdowns allowed
     *    OPCGBD  -  Generic breakdown allowed
     *    OPCRTQ  -  Pre-trip questions
     *    OPCOTQ  -  Post-trip questions
     *    OPCCCE  -  Credit card enabled
     *    OPCSIG  -  Signature enabled
     *    OPCPIV  -  Print invoice
     *    OPCSDA  -  Send data after stop
     *    OPCARE  -  Add return enabled
     *    OPCPAL  -  Pallets enabled
     *    OPCBUL  -  Bulk items enabled
     *    OPCGSS  -  GS1 scanning
     *    OPCGSU  -  GS1 unique
     *    OPCNSR  -  Non scan reason prompt.
     *    OPCFBD  -  Filter by department.
730aA*    OPCSOR  -  Sort items by compartment Y/N.
730bM*    OPCODX  -  Customer on site delivery enable Y/N.
730aA*    OPCODP  -  Customer on site delivery verification period, 5-60.
730aA*    OPCONT  -  On truck picking Y/N.
730aA*    OPCOTP  -  Override truck picking Y/N.
730aA*    OPCNSB  -  No signee button on signature screen Y/N.
     *
     * Data structure
     *
     D opcdta          ds
     D  opccwr                 5      5
     D  opcbda                14     14
     D  opcgbd                15     15
     D  opcrtq                16     16
     D  opcotq                17     17
     D  opccce                18     18
     D  opcsig                19     19
     D  opcpiv                20     20
     D  opcsda                21     21
     D  opcare                76     76
     D  opcpal                79     79
     D  opcbul                82     82
     D  opcgss                89     89
     D  opcgsu                90     90
     D  opcnsr               100    100
     D  opcfbd               101    101
730aAD  opcsor               103    103
730bMD  opcodx               104    104
730aAD  opcodp               105    106  0
730aAD  opcont               107    107
730aAD  opcotp               108    108
730aAD  opcnsb               109    109
     D  opcend               117    117
     *----------------------------------------------------------------
     *  *TRAX1    -  More TRAX customer options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCER   -  Email receipt.
     *    OPCREF  -  Receipt email from.
     *    OPCRES  -  Receipt email subject.
     *
     * Data structure
     *
     D opcdta          ds
     D  opcer                  1      1
     D  opcref                 2     61
     D  opcres                62    116
     D  opcend               117    117
     *
