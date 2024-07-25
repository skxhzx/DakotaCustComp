      *===================================================================
      *
      *  Name .......... C#PIRHLDUC
      *  Description ... PIRHOLD UCI Receiving       info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
700aA *   10/13/15  LMC  7.00
      *     - Created.
700bA *   06/03/16  LMC  7.00b
      *     - Added flag when Scanned value is not found on PO or in
      *       the UPC file. This will give us the ability to allow the
      *       user to Associate the scanned value to a Dakota Item and
      *       add it to the UPC file.
      *
      *===================================================================
      *   Type will be PODTLUCI
      *   key field will be PO/POSEQ/ITEM/UCI Seq#
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLDUC  - File information data structure - PIRHOLD UC
     *----------------------------------------------------------------

     D pirhlducds      ds
     D  uciscanned             1    100
     D  uciNotFound          101    101

     *** End C#FILE15DS ***
