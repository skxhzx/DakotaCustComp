      *===================================================================
      *
      *  Name .......... C#FILET2DS
      *  Description ... Tax-Right TAXREXP file info data structure
      *  Created by .... Robin Clark
      *                  Max Blacknik
      *===================================================================
      *
      * Revisions
      *
HAR A *   07/24/06  RMC  HAR
      *     - Created.
      *
      *===================================================================
      *
      *
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#FILET2DS - File information data structure - TaxRite.
     *----------------------------------------------------------------

     D Filet2DS        ds
     D  ft2filename            1      8
     D  ft2openind             9      9
     D  ft2endoffile          10     10
     D  ft2status             11     15  0
     D  ft2opercode           16     21
     D  ft2routine            22     29
     D  ft2stmtnbr            30     37
     D  ft2recordcd           38     45
     D  ft2messageid          46     52
     D  ft2sourceid           53     54
     D  ft2library            93    102

     *** End C#FILET2DS ***
