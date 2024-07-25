      *===================================================================
      *
      *  Name .......... C#BFCEXCP
      *  Description ... Exception Tracking data structure
      *  Created by .... Rod Roller
      *
      *===================================================================
      *
      * Revisions
      *
650   *   01/15/15  RTR  6.50
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *
      *===================================================================

     d $excpds         ds

     d  $excwhse                      3s 0
     d  $excappl                     15a
     d  $exccat                      15a
     d  $excsev                      10a
     d  $excstat                      2a
     d  $excmsg1                    100a
     d  $excmsg2                    100a
     d  $excdata1                    40a
     d  $excdata2                    40a
     d  $excdata3                    40a
     d  $excval1                     10s 5
     d  $excval2                     10s 5
     d  $excval3                     10s 5
     d  $excgenTS                      z
     d  $excgenUSR                   10a
     d  $excgenPGM                   10a
     d  $exccorTS                      z
     d  $excCORUSR                   10a
     d  $excCORPGM                   10a
     d  $excNOTTS                      z
     d  $excNOTTYP                   10a
     d  $excNOTKEY                   10s 0

