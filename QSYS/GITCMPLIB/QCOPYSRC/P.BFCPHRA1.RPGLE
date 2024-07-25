
     *----------------------------------------------------------------
     * Begin P.BFCPHRAS - Prototypes for BFCPHRASE routines
     *
     *   07/09/08  DAS  6.00  P#00045
     *     - Created
     *
     *----------------------------------------------------------------

     *================================================================
     * Procedure: extractVars
     *================================================================
     *
     *   Usage:
     *
     *      callp   extractVars(pVars)
     *
     *   Return Value:
     *     gVar       -  Global array of variables
     *     gVarSize   -  Global array of variable sizes
     *
     *   Parameters:
     *     pVars      -  Variable string
     *
     *================================================================

     D extractVars     pr
     D  pVars                       100    const

     *================================================================
     * Procedure: fmtPhrase
     *================================================================
     *
     *   Usage:
     *
     *      callp   fmtPhrase(:v2:v3:v4:v5)
     *
     *   Return Value:
     *     varPhrase  -  Formatted phrase
     *
     *   Parameters:
     *     pPhraseId  -  Phrase id
     *     pWhse      -  Warehouse
     *     pEmp#      -  Employee #
     *     pUser      -  Current User (Not job user)
     *     pPgm       -  Calling Program
     *     pItem      -  Item
     *     pWhdp      -  Warehouse Department
     *     pLocation  -  Location (Slot display, area code, etc.)
     *     pTrn#      -  Transaction #
     *     pLcns      -  License number
     *     pLtrn      -  License transction number
     *     pVars      -  Variables
     *
     *================================================================

     D fmtPhrase       pr           100
     D  pPhraseId                     5p 0 const
     D  pPhrase                     100
     D  pWhse                         3s 0 const
     D  pEmp#                         5s 0 const
     D  pUser                        10    const
     D  pPgm                         10    const
     D  pItem                        15    const
     D  pWhdp                         5    const
     D  pLocation                    15    const
     D  pTrn#                         7p 0 const
     D  pLcns                        15    const
     D  pLtrn                         7p 0 const
     D  pVars                       100    const

     *---------------------------------------------------------------
     * fmtVars  -  Format variables
     *
     *   Usage:
     *
     *      eval    varString = fmtVars(v1:v2:v3:v4:v5)
     *
     *   Return Value:
     *      varString  -  Variable string
     *
     *   Parameters:
     *     v1         -  Variable 1 (optional)
     *     v2         -  Variable 2 (optional)
     *     v3         -  Variable 3 (optional)
     *     v4         -  Variable 4 (optional)
     *     v5         -  Variable 5 (optional)
     *
     *---------------------------------------------------------------

     D fmtVars         pr           100
     D  v1                           30    const varying options(*nopass)
     D  v2                           30    const varying options(*nopass)
     D  v3                           30    const varying options(*nopass)
     D  v4                           30    const varying options(*nopass)
     D  v5                           30    const varying options(*nopass)

     *================================================================
     * Procedure: getRecId
     *================================================================
     *
     *   Usage:
     *
     *      callp   getRecId()
     *
     *   Return Value:
     *     recId      -  Record id (yymmddnnnnn)
     *                  -1 returned when error occurs.
     *
     *   Parameters:
     *     pWhse  - Warehouse
     *     pFile  - File
     *
     *================================================================

     D getRecId        pr            11p 0
     D  pWhse                         3s 0 const
     D  pFile                        10    const


     *---------------------------------------------------------------
     * wrtPhrase  -  Write PHRASELOG record
     *
     *   Usage:
     *
     *      callp   wrtPhrase(pPhraseId:pWhse:...)
     *
     *   Return Value:
     *      none
     *
     *   Parameters:
     *     pPhraseId  -  Phrase id
     *     pWhse      -  Warehouse
     *     pEmp#      -  Employee #
     *     pUser      -  Current User (Not job user)
     *     pPgm       -  Calling Program
     *     pItem      -  Item
     *     pWhdp      -  Warehouse Department
     *     pLocation  -  Location (Slot display, area code, etc.)
     *     pTrn#      -  Transaction #
     *     pLcns      -  License number
     *     pLtrn      -  License transction number
     *     v1         -  Variable 1 (optional)
     *     v2         -  Variable 2 (optional)
     *     v3         -  Variable 3 (optional)
     *     v4         -  Variable 4 (optional)
     *     v5         -  Variable 5 (optional)
     *
     *---------------------------------------------------------------

     D wrtPhrase       pr
     D  pPhraseId                     5p 0 const
     D  pWhse                         3s 0 const
     D  pEmp#                         5s 0 const
     D  pUser                        10    const
     D  pPgm                         10    const
     D  pItem                        15    const
     D  pWhdp                         5    const
     D  pLocation                    15    const
     D  pTrn#                         7p 0 const
     D  pLcns                        15    const
     D  pLtrn                         7p 0 const
     D  v1                           30    const varying options(*nopass)
     D  v2                           30    const varying options(*nopass)
     D  v3                           30    const varying options(*nopass)
     D  v4                           30    const varying options(*nopass)
     D  v5                           30    const varying options(*nopass)

     *** End P.BFCPHRAS ***
