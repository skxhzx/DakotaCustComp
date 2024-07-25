      *===================================================================
      *
      *  Name .......... C#FILE14DS
      *  Description ... Tote File TOTEEXP file info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
HAR A *   03/19/12  LMC  CDW
      *     - Created.
      *
      *===================================================================
      *
      *
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#FILE14DS - File information data structure - TOTE File.
     *----------------------------------------------------------------

     D File14DS        ds
     D  f14filename            1      8
     D  f14openind             9      9
     D  f14endoffile          10     10
     D  f14status             11     15  0
     D  f14opercode           16     21
     D  f14routine            22     29
     D  f14stmtnbr            30     37
     D  f14recordcd           38     45
     D  f14messageid          46     52
     D  f14sourceid           53     54
     D  f14library            93    102

     *** End C#FILE14DS ***
