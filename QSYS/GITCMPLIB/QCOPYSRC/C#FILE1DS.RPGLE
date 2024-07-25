
     *----------------------------------------------------------------
     * Begin C#FILE1DS - File information data structure.
     *----------------------------------------------------------------
     *
     * Revisions
     *
640 A*   07/20/12  MLB  6.40
     *     - Enh: Added file library to File1DS.
     *
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54
640 AD  f1library             93    102

     *** End C#FILE1DS ***
