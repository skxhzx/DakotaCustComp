      *===================================================================
      *
      *  Name .......... C#ITEM
      *  Description ... Dakota realtime interface layout for *ITEM
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
416 A *   09/28/01  DAS  4.16
      *     - Created.
      *
416aA *   10/11/01  DAS  4.16a
      *     - Added error flag fields.
      *
      *===================================================================
      *
      * Notes
      *
416 A *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *       3) Create corresponding indicator field.
      *       4) Create corresponding error indicator field.
      *
416 A *   - Each field should have a corresponding indicator field. This
416 A *     field is used to indicate if the field is being used (sent).
416 A *     The only exceptions are the warehouse and item fields, which
416 A *     must be sent every time. In some cases a single indicator can
      *     be used for a group of fields.
      *
416 A *   - Most fields should have a corresponding error flag field. This
416 A *     field is used to indicate if the field caused an error or a
416 A *     warning. Values are 0 = No error/warning, 1 = Error and
416 A *     2 = Warning.
      *
      *===================================================================

     D $Item           ds

     D  $itVer#                       2s 0 Inz(1)
     D  $itwhse                       3  0
     D   $itwhsee                     1
     D  $ititem                      15
     D   $ititeme                     1
     D  $itmitem                     15
     D   $itmiteme                    1
     D   $itmitemu                     n
     D  $itcitem                     15
     D   $itciteme                    1
     D   $itcitemu                     n

      *  PirItem file fields
     D  $ittype                       1
     D   $ittypee                     1
     D   $ittypeu                      n
     D  $itdesc                      30
     D   $itdesce                     1
     D   $itdescu                      n
     D  $itstyp                       1
     D   $itstype                     1
     D   $itstypu                      n
     D  $itwhdp                       5
     D   $itwhdpe                     1
     D   $itwhdpu                      n
     D  $itdesg                       5
     D   $itdesge                     1
     D   $itdesgu                      n
     D  $itactv                       2
     D   $itactve                     1
     D   $itactvu                      n
     D  $itupc                       15
     D   $itupce                      1
     D   $itupcu                       n
     D  $itbld                        2
     D   $itblde                      1
     D   $itbldu                       n
     D  $itven#                      10  0
     D   $itven#e                     1
     D   $itven#u                      n
     D  $itvit#                      15
     D   $itvit#e                     1
     D   $itvit#u                      n
     D  $itpdsc                      15
     D   $itpdsce                     1
     D   $itpdscu                      n
     D  $itum1                        2
     D   $itum1e                      1
     D   $itum1u                       n
     D  $itum2                        2
     D   $itum2e                      1
     D   $itum2u                       n
     D  $itumq2                       3  0
     D   $itumq2e                     1
     D   $itumq2u                      n
     D  $itflg1                       1
     D   $itflg1e                     1
     D   $itflg1u                      n
     D  $itum3                        2
     D   $itum3e                      1
     D   $itum3u                       n
     D  $itumq3                       3  0
     D   $itumq3e                     1
     D   $itumq3u                      n
     D  $itflg2                       1
     D   $itflg2e                     1
     D   $itflg2u                      n
     D  $itulen                       5  2
     D   $itulene                     1
     D   $itulenu                      n
     D  $ituwdt                       5  2
     D   $ituwdte                     1
     D   $ituwdtu                      n
     D  $ituhgt                       5  2
     D   $ituhgte                     1
     D   $ituhgtu                      n
     D  $itcube                       7  3
     D   $itcubee                     1
     D   $itcubeu                      n
     D  $itswgt                       7  2
     D   $itswgte                     1
     D   $itswgtu                      n
     D  $itcwgt                       1
     D   $itcwgte                     1
     D   $itcwgtu                      n
     D  $itreor                       5  0
     D   $itreore                     1
     D   $itreoru                      n
     D  $itrepl                       5  0
     D   $itreple                     1
     D   $itreplu                      n
     D  $itrcvd                       8  0
     D   $itrcvde                     1
     D   $itrcvdu                      n
     D  $itflgd                       1
     D   $itflgde                     1
     D   $itflgdu                      n
     D  $itflgb                       1
     D   $itflgbe                     1
     D   $itflgbu                      n
     D  $itslif                       3  0
     D   $itslife                     1
     D   $itslifu                      n
     D  $itnday                       3  0
     D   $itndaye                     1
     D   $itndayu                      n

      * ItemDef file fields
     D  $idsdef                       2    dim(5)
     D   $idsdefe                     1    dim(5)
     D   $idsdefu                      n   dim(5)
     D  $idtie                        4s 0 dim(5)
     D   $idtiee                      1    dim(5)
     D  $idhigh                       2s 0 dim(5)
     D   $idhighe                     1    dim(5)
     D  $idum                         1    dim(5)
     D   $idume                       1    dim(5)
     D  $idpref                       1    dim(5)
     D   $idprefe                     1    dim(5)

      * ItemDsc file fields
     D  $ixdsc1                      40
     D   $ixdsc1e                     1
     D   $ixdsc1u                      n
     D  $ixdsc2                      40
     D   $ixdsc2e                     1
     D   $ixdsc2u                      n

      * ItemMsc file fields
     D  $imtie                        4s 0
     D   $imtiee                      1
     D   $imtieu                       n
     D  $imhigh                       2s 0
     D   $imhighe                     1
     D   $imhighu                      n
     D  $immflg                       1
     D   $immflge                     1
     D   $immflgu                      n
     D  $imdday                       3  0
     D   $imddaye                     1
     D   $imddayu                      n
     D  $imuday                       3  0
     D   $imudaye                     1
     D   $imudayu                      n
     D  $immday                       3  0
     D   $immdaye                     1
     D   $immdayu                      n
     D  $imwrnc                       1
     D   $imwrnce                     1
     D   $imwrncu                      n
     D  $imrg1c                       3  1
     D   $imrg1ce                     1
     D   $imrg1cu                      n
     D  $imrg2c                       3  1
     D   $imrg2ce                     1
     D   $imrg2cu                      n
     D  $imapck                       1
     D   $imapcke                     1
     D   $imapcku                      n
     D  $imnrpk                       3  0
     D   $imnrpke                     1
     D   $imnrpku                      n
