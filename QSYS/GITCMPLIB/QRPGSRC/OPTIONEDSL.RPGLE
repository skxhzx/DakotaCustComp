     *----------------------------------------------------------------
     *
     *  OPTIONEDS  Redefinition data structures for OPTIONE file
     *  02 November 1995
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  *USER  -  User options
     *----------------------------------------------------------------
     *
     * Revisions
     *
520aA* 07/21/09 GJA 5.20a
     *          Enh:  Add zone or department option, Tote/Drop
     *                fuction, voice LABELDO exist
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N).
     *    OPNXTE  -  Next employee number.
520aA*    OPVYN   -  Processing selection by voice (Y,N).
520aA*    OPZORD  -  Collect selection data by zone or department?
520aA*    OPTBD   -  Tote/Box/Drop?  (Y,N)
     *
     * Data structure
     *
     D opddta          ds
     D  opman                  1      1
     D  opnxte                 2      6  0 inz(0)
     D  opvyn                  7      7
     D  opzord                 8      8
     D  optbd                  9      9
