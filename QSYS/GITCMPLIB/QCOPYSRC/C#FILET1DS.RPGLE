      *===================================================================
      *
      *  Name .......... C#FILET1DS
      *  Description ... Tax-Right TAXRDATA file info data structure
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
     * Begin C#FILET1DS - File information data structure - Tax-Right.
     *----------------------------------------------------------------

     D Filet1DS        ds
     D  ft1filename            1      8
     D  ft1openind             9      9
     D  ft1endoffile          10     10
     D  ft1status             11     15  0
     D  ft1opercode           16     21
     D  ft1routine            22     29
     D  ft1stmtnbr            30     37
     D  ft1recordcd           38     45
     D  ft1messageid          46     52
     D  ft1sourceid           53     54
     D  ft1library            93    102

     *** End C#FILET1DS ***
