      *===================================================================
      *
      *  Name .......... C#DRIPARMP
      *  Description ... Dakota realtime interface parameters - $P parms
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   10/11/01  DAS  4.16
      *     - Created.
      *
417 A *   06/11/03  DAS  4.17
      *     - Added second data parameter.
710aA *   04/18/17  LMC  7.10a
      *     - Added third data parameter.
      *
      *===================================================================

     D $psubcmd        s             10
     D $pprogram       s             10
     D $preturn        s             10
     D $pmessage       s             60
     D $pdata          s            512
417 AD $pdata2         s            512
710aAD $pdata3         s            512
