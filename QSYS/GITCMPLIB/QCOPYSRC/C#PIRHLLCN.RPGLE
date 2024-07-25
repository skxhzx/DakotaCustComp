      *===================================================================
      *
      *  Name .......... C#PIRHLLCN
      *  Description ... PIRHOLD LICENSE Data file info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
650aA *   07/16/14  LMC  6.50
      *     - Created.
      *
      *===================================================================
      *    Type will be POLCNS
      *    key field will be the license#
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLLCN  - File information data structure - PIRHOLD LCN
     *----------------------------------------------------------------

     D pirhllcnds      ds
     D  h1qty                  1      5S 0 INZ(0)
     D  h1uom                  6     10
     D  h1xdk                 11     11
     D  h1umt                 12     12
     D  h1lbl                 13     19s 0 inz(0)
     D  h1trn                 20     26s 0 inz(0)
     D  h1psr                 27     27
     D  h1pcmdone             28     28
     D  h1item                29     43

     *** End C#FILE15DS ***
