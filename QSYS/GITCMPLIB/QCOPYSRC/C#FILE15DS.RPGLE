      *===================================================================
      *
      *  Name .......... C#FILE15DS
      *  Description ... KITITEM file info data structure
      *  Created by .... Kenneth Elder
      *===================================================================
      *
      * Revisions
      *
650aA *   02/20/13  KDE  6.50
      *     - Created.
      *
      *===================================================================
      *
      *
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#FILE15DS - File information data structure - KIITEM
     *----------------------------------------------------------------

     D File15DS        ds
     D  f15filename            1      8
     D  f15openind             9      9
     D  f15endoffile          10     10
     D  f15status             11     15  0
     D  f15opercode           16     21
     D  f15routine            22     29
     D  f15stmtnbr            30     37
     D  f15recordcd           38     45
     D  f15messageid          46     52
     D  f15sourceid           53     54
     D  f15library            93    102

     *** End C#FILE15DS ***
