FasdUAS 1.101.10   ��   ��    k             l    � ����  O     �  	  k    � 
 
     Z      ����  H       l    ����  I   �� ��
�� .coredoexbool        obj   4    �� 
�� 
TxtW  m    ���� ��  ��  ��    k           I   �� ��
�� .sysodisAaleR        TEXT  m       �   R T h i s   s c r i p t   r e q u i r e s   a n   o p e n   t e x t   w i n d o w .��     ��  L    ����  ��  ��  ��        l   ��������  ��  ��        l   ��  ��    � � We need to get the path of this BBEdit package in order to run the script that's in it - the working directory isn't automatically set!     �       W e   n e e d   t o   g e t   t h e   p a t h   o f   t h i s   B B E d i t   p a c k a g e   i n   o r d e r   t o   r u n   t h e   s c r i p t   t h a t ' s   i n   i t   -   t h e   w o r k i n g   d i r e c t o r y   i s n ' t   a u t o m a t i c a l l y   s e t !   ! " ! l   �� # $��   # � � As this is Contents/Scripts/Rust/Generate Implementation.scpt, go up directories three times to get to Contents, and from there we can get to Resources.    $ � % %2   A s   t h i s   i s   C o n t e n t s / S c r i p t s / R u s t / G e n e r a t e   I m p l e m e n t a t i o n . s c p t ,   g o   u p   d i r e c t o r i e s   t h r e e   t i m e s   t o   g e t   t o   C o n t e n t s ,   a n d   f r o m   t h e r e   w e   c a n   g e t   t o   R e s o u r c e s . "  & ' & O    1 ( ) ( r   ! 0 * + * c   ! . , - , n   ! , . / . m   * ,��
�� 
ctnr / n   ! * 0 1 0 m   ( *��
�� 
ctnr 1 n   ! ( 2 3 2 m   & (��
�� 
ctnr 3 l  ! & 4���� 4 I  ! &�� 5��
�� .earsffdralis        afdr 5  f   ! "��  ��  ��   - m   , -��
�� 
alis + o      ���� 0 current_path   ) m     6 6�                                                                                  MACS  alis    t  Macintosh HD               �\OwH+  �u:
Finder.app                                                     ����        ����  	                CoreServices    �\Ag      ���    �u:�u9�u8  6Macintosh HD:System: Library: CoreServices: Finder.app   
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��   '  7 8 7 l  2 2��������  ��  ��   8  9 : 9 l  2 2�� ; <��   ; - ' Get the current line from the document    < � = = N   G e t   t h e   c u r r e n t   l i n e   f r o m   t h e   d o c u m e n t :  > ? > r   2 < @ A @ l  2 : B���� B n   2 : C D C l  6 : E���� E n   6 : F G F 1   8 :��
�� 
SLin G 1   6 8��
�� 
pusl��  ��   D 4   2 6�� H
�� 
TxtW H m   4 5���� ��  ��   A o      ���� 0 
linenumber 
lineNumber ?  I J I r   = F K L K l  = D M���� M n   = D N O N 4   A D�� P
�� 
clin P o   B C���� 0 
linenumber 
lineNumber O 4   = A�� Q
�� 
TxtD Q m   ? @���� ��  ��   L o      ���� 0 linereference lineReference J  R S R r   G P T U T c   G L V W V o   G H���� 0 linereference lineReference W m   H K��
�� 
TEXT U o      ���� 0 linecontents lineContents S  X Y X l  Q Q��������  ��  ��   Y  Z [ Z l  Q Q�� \ ]��   \ - ' Run the script with this line as stdin    ] � ^ ^ N   R u n   t h e   s c r i p t   w i t h   t h i s   l i n e   a s   s t d i n [  _ ` _ r   Q v a b a I  Q r�� c��
�� .sysoexecTEXT���     TEXT c b   Q n d e d b   Q j f g f b   Q ` h i h b   Q \ j k j m   Q T l l � m m 
 e c h o   k n   T [ n o n 1   W [��
�� 
strq o o   T W���� 0 linecontents lineContents i m   \ _ p p � q q  |   g n   ` i r s r 1   e i��
�� 
strq s n   ` e t u t 1   a e��
�� 
psxp u o   ` a���� 0 current_path   e m   j m v v � w w 0 R e s o u r c e s / i m p l - g e n e r a t o r��   b o      ���� 
0 output   `  x y x l  w w��������  ��  ��   y  z { z l  w w�� | }��   |   Set it to the output    } � ~ ~ *   S e t   i t   t o   t h e   o u t p u t {   �  I  w ��� ���
�� .coredelonull���    obj  � n   w | � � � 2   x |��
�� 
cha  � o   w x���� 0 linereference lineReference��   �  � � � r   � � � � � o   � ����� 
0 output   � n       � � � m   � ���
�� 
ctxt � o   � ����� 0 linereference lineReference �  ��� � I  � ��� ���
�� .miscslctnull��� ��� obj  � n   � � � � � 8   � ���
�� 
cins � o   � ����� 0 linereference lineReference��  ��   	 m      � ��                                                                                  R*ch  alis    N  Macintosh HD               �\OwH+  �uY
BBEdit.app                                                     ���ҋ�f        ����  	                Applications    �\Ag      ҋ�f    �uY  %Macintosh HD:Applications: BBEdit.app    
 B B E d i t . a p p    M a c i n t o s h   H D  Applications/BBEdit.app   / ��  ��  ��     ��� � l     ��������  ��  ��  ��       
�� � � ��� � � �������   � ����������������
�� .aevtoappnull  �   � ****�� 0 current_path  �� 0 
linenumber 
lineNumber�� 0 linereference lineReference�� 0 linecontents lineContents�� 
0 output  ��  ��   � �� ����� � ���
�� .aevtoappnull  �   � **** � k     � � �  ����  ��  ��   �   �  ����� �� 6������������������������ l�� p�� v��������������
�� 
TxtW
�� .coredoexbool        obj 
�� .sysodisAaleR        TEXT
�� .earsffdralis        afdr
�� 
ctnr
�� 
alis�� 0 current_path  
�� 
pusl
�� 
SLin�� 0 
linenumber 
lineNumber
�� 
TxtD
�� 
clin�� 0 linereference lineReference
�� 
TEXT�� 0 linecontents lineContents
�� 
strq
�� 
psxp
�� .sysoexecTEXT���     TEXT�� 
0 output  
�� 
cha 
�� .coredelonull���    obj 
�� 
ctxt
�� 
cins
�� .miscslctnull��� ��� obj �� �� �*�k/j  �j OhY hO� )j �,�,�,�&E�UO*�k/�,�,E�O*�k/��/E�O�a &E` Oa _ a ,%a %�a ,a ,%a %j E` O�a -j O_ �a -FO�a 3j U ��alis    �  Macintosh HD               �\OwH+  ��ZContents                                                       ��^��a�        ����  	                Rust.bbpackage    �\Ag      ��S�    ��Z��.��� 	D6 	D' 	D" ��  aMacintosh HD:Users: ben: Library: Application Support: BBEdit: Packages: Rust.bbpackage: Contents     C o n t e n t s    M a c i n t o s h   H D  MUsers/ben/Library/Application Support/BBEdit/Packages/Rust.bbpackage/Contents   /    
��  �� �  � �  ����� �  ����
�� 
TxtD� 
�� 
clin�� � � � � $ i m p l   E r r o r   f o r   F o o � � � � i m p l   E r r o r   f o r   F o o   {          f n   d e s c r i p t i o n ( & s e l f )   - >   & s t r   {                  < # . . . # >          }           f n   c a u s e ( & s e l f )   - >   O p t i o n < & E r r o r >   {                  < # . . . # >          }  }��  ��   ascr  ��ޭ