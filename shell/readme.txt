1 ��ֵ��test������ (=  /  -eq)

2 shell���ܴ����ⲿ������$0Ϊ�ű����֣�$1Ϊ��һ��������$2�ڶ�������$9�ھŸ��������Ҫ���������Ҫʹ�ô����ţ���${10}

$MINPARAMS  ���ýű���Ҫ���ݵĲ�������
$#  ʵ�ʴ��ݸ�shell�Ĳ����ĸ���

if [ $# -lt $MINPARAMS ];then echo "error,need at least $MINPARAMS ��������"

3 ֱ�����ñ�����˫�������ñ���������

a=`ls -l`

echo $a  #�������հס����е�

echo "$a" #�����հס����У���ά��ԭ��ʽ

4 echo -n ʹ��������У���������ͬһ��λ�������

5 a=(1 2 3 4)

������ֵ��a��Ϊһ�����飬echo ${a[1]},�����2

6 ~�����Ŀ¼��~+����ǰ����Ŀ¼ ~-������һ������Ŀ¼

7 -�������ض���stdin��stdout

(cd /usr/local/src && tar cf - .) | (cd /mnt && tar xpvf -)

��������������ǰ�/usr/local/src�µ���������ת�Ƶ�/mnt�£�Ҳ������ԴĿ¼���ļ�������ض���stdout,Ȼ��Ŀ��Ŀ¼�������������Ϊstdin���н���Ĳ�����ʡ������ʵ���ɴ���ļ���Ȼ���ٶ������ʵ����ļ����н���Ĺ��̡�()����һ��������

8 if [ -z "$1" ]  if [ -n "$1" ]
shell�ű����жϲ����Ƿ񴫵�,z������Ϊ�գ�n����Ϊ��

9 shift ��shell�ű��Ĳ��������ƶ�һλ��ԭ����$2��$1,$3��$2����

until [ -z "$1" ]  #��ӡ���в�����ֱ�����ڴ���$1,�����в��������ù⡣
do 
echo -n $1
shift          #shift������������
done

10 ����������ʵ�ַ�
     count=$[ $count + 1 ]  
     
     count=$(($count+1))
     
     let "count += 1"
done

11 if�ܹ����ԵĲ������������е����ݣ��������������κ�����

if grep 111 file
then
echo "���ļ�file�����ٰ���һ���ؼ���111"
else
echo "�������˹ؼ���"
fi

12 (()) �ṹ��������������������߱Ƚϣ�������Ϊ0����1����������0����0
    ((0))
    ((1))
    ((5>4))
    ((5/4))

13 shell�е��ļ�����
-s �ļ����Ȳ�Ϊ0
-g �ļ��Ƿ�������sgid
-u �ļ��Ƿ�������suid
f1 -nt f2 �ļ�f1���ļ�f2��
f1 -ot f2 �ļ�f1��f2��
-e
-d
-f
-r
-w
-x
���в��Զ������ã�ȡ��

�����Ƚ� 
-eq 
-ne
-gt  -ge
-lt  -le
�ַ����Ƚ�
=
==
!=
-z �ַ���Ϊnull,������Ϊ0
-n ��Ϊnull

============================================================
�ַ�������
14 �����ַ�������

${#string}

expr length $string

expr "$string" : '.*'

15 ��ȡ�ַ���
${string:positon:length}
���ӣ�
stringZ=1234567
echo ${stringZ:0}     1234567
echo ${stringZ:1}     234567
echo ${stringZ:3:2}   45 

#������������ַ���
echo ${stringZ: -3}   567  һ��Ҫע��-3��ð��֮����һ���ո����

16 ��ȥ�ַ��� ��ע���ǽ�ȥ�����ǽ�ȡ��
���ӣ�
stringZ=abcABC123ABCabc
echo ${stringZ#a*C}   ���ƥ�䣬ȥ����������һ����ƥ��a*Cģʽ���Ӵ��������123ABCabc
echo $stringZ##a*C�� ��Զƥ�䣬ȥ����������һ����ƥ��a*Cģʽ���Ӵ��������abc

echo ${stringZ%b*c} ���ƥ�䣬���ұ߿�ʼƥ�䣬�����abcABC123ABCa

echo ${stringZ%%b*c} ��Զƥ�䣬���ұ߿�ʼƥ�䣬�����a


17 �Ӵ��滻
����
stringZ=abcABC123ABCabc

echo ${stringZ/abc/xyz} ����һ��abc�滻Ϊxyz,���ΪxyzABC123ABCabc

echo ${stringZ//abc/xyz} ������abc�滻Ϊxyz

echo ${stringZ/#abc/xyz} �滻�ַ�����ͷ��abc

echo ${stringZ/%abc/xyz} �滻��β��abc

18 �����滻
$(cmd)
`cmd`
${var:-string} #���$varΪ������string�滻${var:-string},$var��Ϊ��
${var:=string} #���$varΪ������string�滻${var:=string},$var����ֵΪstring
${var:+string} #���$var��Ϊ������string�滻${var:+string},���$varΪ�����滻
${var:?string} #���$var��Ϊ������$var��ֵ�滻${var:?string},$varΪ�յĻ�string���������׼���

19 $(()) �ṹ

$ echo $((3+2)) 
5 
$ echo $((3>2)) 
1 
$ echo $((25<3 ? 2:3)) # ��Ԫ���ʽ������?���ʽ1:���ʽ2������������������б��ʽ1���������б��ʽ2
3 
$ echo $var

$ echo $((var=2+3)) 
5 
$ echo $var 
5 
$ echo $((var++)) 
5 
$ echo $var 
6 

# set -eux
# set -o pipefail
# shell�ű���ͷ�������������
# set -e: ��������ķ���ֵ�������˳������ű�
# set -u: ����δ����ı������˳��ű�
# set -x: ����ģʽ����ӡִ�еľ�������
# set -o pipefail: set -e�ڹܵ�ģʽ�»�ʧЧ����ΪֻҪ�ܵ������һ������ִ�гɹ��򷵻���
# set -o pipefail����Ϊ�˽��������⣬ֻҪ�ܵ�����һ������ִ��ʧ�����˳��ű�

