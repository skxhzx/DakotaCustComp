      *===================================================================
      *
      *  Name .......... C#PIRHLDUE
      *  Description ... PIRHOLD UCI Extracted  info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
700aA *   02/19/16  LMC  7.00
      *     - Created.
      *
      *===================================================================
      *   Type will be PODTLUCIE
      *   key field will be PO for uci receiving only
      *   Should be only one record for session/po in this file at anytime
      *   Record will hold extract data from cvtbar, so we don't have to
      *   call cvtbar multiple times in the process.
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLDUE  - File information data structure - PIRHOLD UCIE
     *----------------------------------------------------------------

     D pirhldueds      ds
     D  UCIdata1               1    256
     D  UCIdata2             257    512

