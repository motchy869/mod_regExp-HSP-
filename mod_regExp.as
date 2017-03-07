/*
	mod_regExp
	
	HSP3�p���K�\�����W���[��
	
	ver 1.2.0
*/

#define global DEBUGMODE

#ifdef DEBUGMODE
	#define global assertEx(%1)	assert (%1)
#else
	#define global assertEx(%1) if(0){}	//���Ԃ�œK���ŏ�����
#endif

#define global TRUE		1
#define global FALSE	0
#define global NULL		-1

#define global VARTYPE_MODULE	5

//���Z�q�^�C�v
	#enum global OC_INVALID=-1
	#enum global OC_SIMPLE	//�P��������
	#enum global OC_ANY_ENG_LET	/*\w*/
	#enum global OC_NOT_ENG_LET	/*\W*/
	#enum global OC_ANY_SPACE	/*\s*/
	#enum global OC_NOT_SPACE	/*\S*/
	#enum global OC_ANY_DIGIT	/*\d*/
	#enum global OC_NOT_DIGIT	/*\D*/
	#enum global OC_ANY	//.
	#enum global OC_BOUND	/*\b*/
	#enum global OC_NOT_BOUND	/*B*/
	#enum global OC_LINEHEAD	//�s��
	#enum global OC_LINEEND	//�s��
	#enum global OC_JOIN	//�A�����Z�q
	#enum global OC_OR	//|
	#enum global OC_ZERO_OR_ONE	//?
	#enum global OC_ZERO_OR_MORE	//*?
	#enum global OC_ZERO_OR_MORE_GREEDY	//*
	#enum global OC_ONE_OR_MORE	//+?
	#enum global OC_ONE_OR_MORE_GREEDY	//+
	#enum global OC_N	//{n}
	#enum global OC_N_	//{n,}
	#enum global OC_NM	//{n,m}
	#enum global OC_SET	//�����W��
	#enum global OC_ANTI_SET	//���O�����W��
	#enum global OC_PACK	//(?:) �X�ɉ�́A��������A�ŏI�I�ȍ\���؂ɂ͎c��Ȃ��B
	#enum global OC_POSITIVE_LOOKAHEAD	//(?=)
	#enum global OC_NEGATIVE_LOOKAHEAD	//(?!)
	#enum global OC_CAPTURE	//�L���v�`��
	#enum global OC_DUMMY

#module Capt_info_regExp count, idx, len	//�L���v�`�����N���X(Capt_info�N���X)
	/*
		count : �L���v�`�����ꂽ��
		idx : �L���v�`�����ꂽ�ʒu�̔z��
		len : �L���v�`�����ꂽ�����̔z��
	*/
	tmp=0
	#modinit
		count=0 : idx=0 : len=0
		mref tmp,2
		return tmp
	
	#modcfunc local get_count
		return count
	#modcfunc local get_idx int id_	//id_ �Ԗڂ̃L���v�`���ʒu
		if ((id_<0)||(id_>=count)) {return -1}
		return idx(id_)
	#modcfunc local get_len int id_	//id_ �Ԗڂ̃L���v�`������
		if ((id_<0)||(id_>=count)) {return -1}
		return len(id_)
	
	#modfunc local add int idx_, int len_
		assertEx ((idx_>=0)&&(len_>=0))
		idx(count)=idx_ : len(count)=len_
		count++
		return
#global

#module Node_regExp oc, string, n,m, addr_left, addr_right	//�p�^�[���̍\���؂̃m�[�h�̃N���X
	/*
		oc : ���Z�q
		
		string : ������
			oc=OC_SIMPLE �̏ꍇ�͂��̕�����
			oc=OC_SET, OC_ANTI_SET �̏ꍇ�͂��̕����W��
			����ȊO�� oc �ł͕K�{�ł͂Ȃ����A�f�o�b�O���ɖ؂̒��g��\������\���l����΁A������������������Ă����̂��悢�B
		
		n,m : oc=OC_N, OC_N_, OC_NM �̏ꍇ�� n,m
			
		addr_left, addr_right : ���E�̃m�[�h�̃A�h���X(���W���[���ϐ��z��ɂ�����C���f�b�N�X)
			�w���m�[�h�������Ƃ��� NULL
	*/

	tmp=0
	
	#modcfunc local is_oc_known int oc_	//(�f�o�b�O�p)���m�̉��Z�q���ǂ���
		return ((oc_>=OC_INVALID)&&(oc_<OC_DUMMY))
	
	#modcfunc local node_exists int addr_	//(�f�o�b�O�p)���̃m�[�h�����݂��邩
		return node_exists@mod_regExp(addr_)
	
	#modinit int oc_, str string_, int n_,int m_, int addr_left_, int addr_right_
		assertEx (is_oc_known(thismod, oc_))
		#ifdef DEBUGMODE
			if ((oc_==OC_SIMPLE)||(oc_==OC_SET)||(oc_==OC_ANTI_SET)) {
				assertEx (string_!="")
			}
		#endif
		assertEx ((n_>=0)&&(m_>=0)&&(((oc_==OC_NM)&&(n_<=m_))||(oc_!=OC_NM)))
		assertEx ((addr_left_==NULL)||node_exists(thismod, addr_left_))
		assertEx ((addr_right_==NULL)||node_exists(thismod, addr_right_))
		
		oc=oc_
		string=string_
		n=n_ : m=m_
		addr_left=addr_left_
		addr_right=addr_right_
		mref tmp,2
		return tmp
	
	#modcfunc local get_oc
		return oc
	
	#modcfunc local get_string
		return string
	
	#modcfunc local get_n
		return n
	#modcfunc local get_m
		return m
	
	#modcfunc local get_addr_left
		return addr_left
	#modcfunc local get_addr_right
		return addr_right
	
	#modcfunc local is_char_in_set int char_, local flg	//���̕����������W���ɑ����邩�H
		assertEx ((oc==OC_SET)||(oc==OC_ANTI_SET))
		
		flg=FALSE
		repeat strlen(string)
			if (char_==peek(string,cnt)) {flg=TRUE : break}
		loop
		return flg
#global

#module mod_regExp
	tree=0	//�\����
	addr_root=0	//���̃A�h���X
	
	#deffunc local clear_mod_var_array array array_	//���W���[���ϐ��z����N���A����
		if (vartype(array_)!=VARTYPE_MODULE) {return}
		foreach array_ : delmod array_ : loop
		return
	
	#deffunc local init	//������
		control_char_set = '(',')', '{','}', '[',']', '\\', '^', '$', '|', '?', '+', '*', '.'	//���䕶���W��
		return
	
	#defcfunc local is_number int char_//�������H
		return (char_>='0')&&(char_<='9')
	
	#defcfunc local is_eng_letter int char_	//�p�P����\������1����(a-zA-Z_0-9)���H
		return (((char_>='a')&&(char_<='z'))||((char_>='A')&&(char_<='Z'))||(char_=='_')||((char_>='0')&&(char_<='9')))
	
	#defcfunc local is_space int char_	//�󔒕���(���p�X�y�[�X �^�u \r \n)���H
		return ((char_==' ')||(char_=='\t')||(char_=='\r')||(char_==10))
	
	#defcfunc local is_control_char int char_, local flg	//���䕶�����H
		flg=FALSE
		foreach control_char_set
			if (char_==control_char_set(cnt)) : flg=TRUE : break
		loop
		return flg
	
	#defcfunc local is_escaped_control_char int char_	//\ �ƍ��킹�Đ��䕶���ɂȂ�(\d �� d ��)���H
		return ((char_=='w')||(char_=='W')||(char_=='s')||(char_=='S')||(char_=='d')||(char_=='D')||(char_=='/')||(char_=='b')||(char_=='B'))
	
	#defcfunc local is_open_bracket int char_	//����͊J�����ʂ��H
		return (char_=='(')||(char_=='{')||(char_=='[')
	
	#defcfunc local is_close_bracket int char_	//����͕����ʂ��H
		return (char_==')')||(char_=='}')||(char_==']')
	
	#defcfunc local is_first_byte_of_zenkaku int char_	//�S�p������1�o�C�g�ڂ��ǂ���
		return (((char_>=129)&&(char_<=159))||((char_>=224)&&(char_<=252)))
	
	#defcfunc local convert_escaped_char int char_	//\�̎��̂P�o�C�g����ϊ����ĕ����R�[�h��Ԃ�
		switch char_
			case 't' : return '\t'
			case 'r' : return '\r'
			case 'n' : return 10
			default : return char_
		swend
		assertEx(FALSE)
		return
	
	#defcfunc local is_valid_sjis_string var string_, int left_, int right_, local flg, local left	//�����SJIS�����񂩁H
		/*
			string_ : ��͑Ώە�����(�ϐ�)
			left_ : right_ : ��͊J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
		*/
		assertEx((left_>=0)&&(right_>=0)&&(left_<=right_))
		assertEx(right_<=strlen(string_))
		
		flg=TRUE
		left=left_
		repeat
			if (left==right_) {break}
			if (is_first_byte_of_zenkaku(peek(string_, left))) {
				if (left==right_-1) {flg=FALSE : break}
				left+=2
				continue
			}
			left++
		loop
		return flg
	
	#defcfunc local dont_need_left_operand int oc_	//���I�y�����h�s�v��?
		return ((oc_==OC_SIMPLE)||(oc_==OC_ANY_ENG_LET)||(oc_==OC_NOT_ENG_LET)||(oc_==OC_ANY_SPACE)||(oc_==OC_NOT_SPACE)||(oc_==OC_ANY_DIGIT)||(oc_==OC_NOT_DIGIT)||(oc_==OC_ANY)||(oc_==OC_BOUND)||(oc_==OC_NOT_BOUND)||(oc_==OC_LINEHEAD)||(oc_==OC_LINEEND)||(oc_==OC_SET)||(oc_==OC_ANTI_SET)||(oc_==OC_PACK)||(oc_==OC_POSITIVE_LOOKAHEAD)||(oc_==OC_NEGATIVE_LOOKAHEAD)||(oc_==OC_CAPTURE))

	#defcfunc local node_exists int addr_	//(�f�o�b�O�p)���̃m�[�h�����݂��邩
		if (addr_==NULL) {return FALSE}
		return varuse(tree(addr_))
	
	#defcfunc local find_close_bracket var tgt_, int code_, int left_, int right_, int char_set_mode_, local char_set_mode, local left, local idx, local depth, local char	//�Ή���������ʂ̌���
		/*
			tgt_ : �^�[�Q�b�g������(�ϐ�)
			code_ : �����ʂ̕����R�[�h
			left_, right_ : �����J�n�ʒu(�J�����ʂ̉E��), �����I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
			char_set_mode_ : [] �����[�h�t���O�B[]�����[�h�ł� [(){}�𕁒ʂ̕����Ɠ���Ɉ����B
			
			[�߂�l]
				(-1,other) : (����, �����ʒu)
		*/
		assertEx (is_close_bracket(code_))
		assertEx ((left_>=0)&&(right_>=0)&&(left_<=right_))
		assertEx (right_<=strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		
		char_set_mode=char_set_mode_
	
		idx=-1 : depth=1 : left=left_
		repeat
			if (left==right_) {break}
			char=peek(tgt_, left)
			
			if (char=='\\') {
				if (left==right_-1) {break}	//\ �̉E����
				left+=2
				continue
			}
			if (char_set_mode) {
				if (char==']') {
					if ((depth==1)&&(code_==']')) {idx=left : break}
					depth--
					char_set_mode=FALSE
				}
				left++
				continue
			}
			if (is_first_byte_of_zenkaku(char)) {left+=2 : continue}
			if (char=='[') {
				depth++
				char_set_mode=TRUE
				left++
				continue
			}
			if (is_open_bracket(char)) {depth++}
			if ((depth==1)&&(char==code_)) {idx=left : break}
			if (is_close_bracket(char)) {depth--}
			left++
		loop
		return idx
	
	#defcfunc local parse_in_braces var tgt_, int left_, int right_, var n_, var m_, var errIdx_, local flg_error, local left, local left2, local char	//{}���̃p�[�X
		/*
			tgt_ : �^�[�Q�b�g������(�ϐ�)
			left_, right_ : �p�[�X�J�n�ʒu({�̉E��),�I���ʒu(}�̈ʒu)
			n_, m_ : �ǂݎ���� {n,m} �� n,m (int)��ۑ�
			errIdx_ : (�\���G���[�̂Ƃ�)�G���[���������ʒu��ۑ�
			
			[�߂�l]
				OC_INVALID, OC_N, OC_N_, OC_NM �̂����ꂩ
			
			[���l]
				{}�̒��ɂ͔��p������,�݂̂̑��݂�����
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		assertEx ((peek(tgt_, left_-1)=='{')&&(peek(tgt_, right_)=='}'))
		
		flg_error=FALSE
		
		//n �𓾂�
		left=left_
		repeat
			if (left==right_) {break}
			char=peek(tgt_, left)
			if (char==',') {
				if (left==left_) {flg_error=TRUE}	//, �̍�����
				break
			}
			if (is_number(char)==FALSE) {flg_error=TRUE : break}
			left++
		loop
		if (flg_error) {errIdx_=left : return OC_INVALID}
		
		//���̎��_�� , ��1�������ꍇ�� left �͂��̈ʒu�Ŏ~�܂��Ă���B
		//, �����������ꍇ�� left==right_ ������
		n_=int(strmid(tgt_, left_, left-left_))
		if (left==right_) {return OC_N}
		if (left==right_-1) {return OC_N_}
		//���̎��_�� left+2 <= right_ ������
		
		//m�𓾂�
		left2=left+1	//��������, �̉E�ׂɈړ�
		repeat
			if (left2==right_) {break}
			char=peek(tgt_, left2)
			if (is_number(char)==FALSE) {flg_error=TRUE : errIdx_=left2 : break}
			left2++
		loop
		if (flg_error) {return OC_INVALID}
		m_=int(strmid(tgt_, left+1, right_-left+1))
		if (n_>m_) {errIdx_=left+1 : return OC_INVALID}
		
		return OC_NM
	
	#defcfunc local parse_in_boxBrackets var tgt_, int left_, int right_, var charSet_, var errIdx_, local oc, local left, local left2, local char, local c1, local c2, local strbuf, local c	//[]���̃p�[�X
		/*
			tgt_ : �^�[�Q�b�g������(�ϐ�)
			left_, right_ : �p�[�X�J�n,�I���ʒu
			charSet_ : �ǂݎ���������W����ۑ�
			errIdx_ : (�\���G���[�̂Ƃ�)�G���[���������ʒu��ۑ�
			
			[�߂�l]
				OC_INVALID, OC_SET, OC_ANTI_SET �̂����ꂩ
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		assertEx ((peek(tgt_, left_-1)=='[')&&(peek(tgt_, right_)==']'))
		
		//OC_SET �� OC_ANTI_SET ������
		char=peek(tgt_, left_)
		left=left_
		if (char=='^') {oc=OC_ANTI_SET : left++} else {oc=OC_SET}
		if (left==right_) {return OC_INVALID}
	
		//�W���擾
		charSet_=""
		left2=left
		repeat
			if (left2==right_) {break}
			char=peek(tgt_, left2)
			if (char='\\') {
				if (left2==right_-1) {oc=OC_INVALID : errIdx_=left2 : break}	//\�̉E����
				strbuf="" : poke strbuf, 0, convert_escaped_char(peek(tgt_, left2+1))
				charSet_+=strbuf
				left2+=2
				continue
			}
			if (char=='-') {
				if ((left2==left)||(left2==right_-1)) {charSet_+="-" : left2++ : continue}	//������-����
				
				//�����R�[�h�͈͎w��
				poke charSet_, strlen(charSet_)-1, 0	//���O�ɓo�^����������������
				c1=peek(tgt_, left2-1) : c2=peek(tgt_, left2+1)
				if (c1>c2) {oc=OC_INVALID : errIdx_=left2 : break}
				sdim strbuf, c2-c1+2 : c=c1 : repeat c2-c1+1 : poke strbuf, cnt, c : c++ : loop
				charSet_+=strbuf
				left2+=2
				continue
			}
			charSet_+=strmid(tgt_, left2, 1)
			left2++
		loop
		
		return oc
	
	#defcfunc local is_simplifiable var tgt_, int left_, int right_, local flg, local left, local char	//�Ȗ񉻉\���H
		/*
			tgt_ : ���K�\���p�^�[���S��(�ϐ�)
			left_, right_ : ��͊J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<=strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		
		flg=TRUE : left=left_
		repeat
			if (left==right_) {break}
			char=peek(tgt_, left)
			if (is_first_byte_of_zenkaku(char)) {left+=2 : continue}
			if (char=='\\') {
				if (left==right_-1) {flg=FALSE : break}	//\ �̉E������
				//\ �̉E���𒲂ׂ�
				char=peek(tgt_, left+1)
				if (is_escaped_control_char(char)) {flg=FALSE : break}
				if (is_first_byte_of_zenkaku(char)) {left+=3} else {left+=2}
				continue
			}
			if (is_control_char(char)) {	//\ �ȊO�̐��䕶��
				switch char
					case '^'
						if (left==0) {flg=FALSE : break}	//OC_LINEHEAD
						swbreak
					case '$'
						if (left==strlen(tgt_)-1) {flg=FALSE : break}	//OC_LINEEND
						swbreak
					default
						flg=FALSE : break
				swend
				left++
				continue
			}
			//��L�ȊO�̕���
			left++
		loop
		return flg
	
	#defcfunc local simplify var tgt_, int left_, int right_, local string_simplified, local len_simplified, local left, local char	//�Ȗ񉻁B�G�X�P�[�v�V�[�P���X����������B
		/*
			tgt_ : ���K�\���p�^�[���S��(�ϐ�)
			left_, right_ : �Ȗ񉻊J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
			
			[�߂�l]
				�Ȗ񉻌�̕�����
			
			[���l]
				���͂��Ȗ񉻉\�ł���Ɖ��肵�Ă���
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<=strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		assertEx (is_simplifiable(tgt_, left_, right_))
		
		sdim string_simplified, strlen(tgt_)+1 : len_simplified=0
		left=left_
		repeat
			if (left==right_) {break}
			char=peek(tgt_, left)
			if (is_first_byte_of_zenkaku(char)) {
				poke string_simplified, len_simplified, char
				poke string_simplified, len_simplified+1, peek(tgt_, left+1)
				len_simplified+=2
				left+=2 : continue
			}
			if (char=='\\') {
				char=peek(tgt_, left+1)	//��\ �̉E���͋�łȂ�(��Ȗ񉻉\)
				if (is_first_byte_of_zenkaku(char)) {left++ : continue}
				poke string_simplified, len_simplified, convert_escaped_char(char) : len_simplified++
				left+=2 : continue
			}
			//��L�ȊO�̕���
			poke string_simplified, len_simplified, char : len_simplified++
			left++
		loop
		return string_simplified
	
	#defcfunc local get_one_simplifiable_string var tgt_, int left_, int right_, var simplified_string_, var errIdx_, local flg_error, local flg_stop, local left, local delta_left_prev, local byte_len_simplified, local char_count_simplified, local is_prev_zenkaku, local char	//��ԍ����̊Ȗ񉻉\��������擾
		/*
			tgt_ : ���K�\���p�^�[���S��(�ϐ�)
			left_, right_ : ��͊J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
			simplified_string_ : �Ȗ񉻌�̕������ۑ�
			errIdx_ : (�\���G���[�̂Ƃ�)�G���[�����ʒu
			
			[�߂�l]
				(-1,0,larger) : (�\���G���[, �Y���Ȃ�, ���o�����Ȗ񉻉\������(tgt_��)�̒���)
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<=strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		
		flg_error=FALSE
		sdim simplified_string_, strlen(tgt_)+1
		left=left_
		delta_left_prev=0	//���O�� left �̑���
		byte_len_simplified=0 : char_count_simplified=0	//�Ȗ񉻌㕶����̃o�C�g��, ������
		is_prev_zenkaku=FALSE//���O�ɒ��ׂ��������S�p���ǂ���
		repeat
			if (left==right_) {break}
			char=peek(tgt_, left)
			
			//�S�p����
			if (is_first_byte_of_zenkaku(char)) {
				poke simplified_string_, byte_len_simplified, char
				poke simplified_string_, byte_len_simplified+1, peek(tgt_, left+1)
				byte_len_simplified+=2 : char_count_simplified++ : is_prev_zenkaku=TRUE
				left+=2 : delta_left_prev=2
				continue
			}
			
			//\
			if (char=='\\') {
				if (left==right_-1) {flg_error=TRUE : errIdx_=left : break}	//\ �̉E����
				char=peek(tgt_, left+1)
				if (is_first_byte_of_zenkaku(char)) {left++ : delta_left_prev=1 : continue}
				if (is_escaped_control_char(char)) {break}
				char=convert_escaped_char(char)
				poke simplified_string_, byte_len_simplified, char
				byte_len_simplified++ : char_count_simplified++ : is_prev_zenkaku=FALSE
				left+=2 : delta_left_prev=2
				continue
			}
			
			//\�ȊO�̐��䕶��
			if (is_control_char(char)) {
				switch char
					case '^'
						if (left==0) {break}	//OC_LINEHEAD
						swbreak
					case '$'
						if (left==strlen(tgt_)-1) {break}	//OC_LINEEND
						swbreak
					default
						if ((char=='?')||(char=='*')||(char=='+')||(char=='{')) {	//���I�y�����h�K�{�̉��Z�q
							//���ׂ�1���������̉��Z�q�Ɋ��蓖�Ă�
							if (char_count_simplified>=2) {	//char �̍���2�����ȏ゠��ꍇ�͂��̉E�[��1������؂藣���� char �ɏ[�Ă�
								if (is_prev_zenkaku) {
									wpoke simplified_string_, byte_len_simplified-2,0
									byte_len_simplified-=2
								} else {
									poke simplified_string_, byte_len_simplified-1, 0
									byte_len_simplified-=1
								}
								char_count_simplified--
								left-=delta_left_prev
							}
						}
						break
				swend
				poke simplified_string_, byte_len_simplified, char
				byte_len_simplified++ : char_count_simplified++ : is_prev_zenkaku=FALSE
				left++ : delta_left_prev=1
				continue
			}
			
			//��L�ȊO�̕���
			poke simplified_string_, byte_len_simplified, char
			byte_len_simplified++ : char_count_simplified++ : is_prev_zenkaku=FALSE
			left++ : delta_left_prev=1
		loop
		
		if (flg_error) {return -1}
		return left-left_
	
	#defcfunc local get_one_oc	var tgt_, int left_, int right_, var len_, var node_, var errIdx_, local len_left_simple_string, local simplified_string, local char, local right2, local oc, local n, local m, local strbuf//��ԗD�揇�ʂ̒Ⴂ�I�y�R�[�h(�I�y�����h���܂�)���擾
		/*
			tgt_ : ���K�\���p�^�[���S��(�ϐ�)
			left_, right_ : ��͊J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)�B�������I�y�R�[�h�̈ʒu�͏�� left_ �ɂȂ�B
			len_ : �������I�y�R�[�h�̒���(tgt_ ��)��ۑ�
			node_ : (�\��������ȂƂ�)Node_regExp �^�̕ϐ���ۑ��B�����ɃI�y�R�[�h�̏������ĕԂ��B(varuse(node)==FALSE ������)
			errIdx_ : (�\���G���[�̂Ƃ�)�G���[���������ʒu
			
			[�߂�l]
				���Z�q�^�C�v�̂����ꂩ
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<=strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		
		//���ɊȖ񉻉\�����񂪂��邩�Ȃ������d�v
		len_left_simple_string=get_one_simplifiable_string(tgt_, left_, right_, simplified_string, errIdx_)
		if (len_left_simple_string==-1) {return OC_INVALID}
		if (len_left_simple_string>=1) {
			len_=len_left_simple_string
			newmod node_, Node_regExp, OC_SIMPLE, simplified_string, 0,0, NULL,NULL
			return OC_SIMPLE
		}
			char=peek(tgt_, left_)	//�K�����䕶��
			switch char
				case '('
					//�Ή����� ) ��T��
					right2=find_close_bracket(tgt_, ')', left_+1, right_, FALSE)
					if (right2==-1) {errIdx_=left_ : return OC_INVALID}
					len_=right2+1-left_
					if (len_<=2) {errIdx_=left_ : return OC_INVALID}	//���g����
					
					//( ), (?:), (?=), (?!) �̂ǂꂩ?
					char=peek(tgt_, left_+1)
					if (char=='?') {
						if (len_<=4) {errIdx_=left_+1 : return OC_INVALID}	//(?), (?:), (?=) ��
						char=peek(tgt_, left_+2)
						switch char
							case ':' : oc=OC_PACK : swbreak
							case '=' : oc=OC_POSITIVE_LOOKAHEAD : swbreak
							case '!' : oc=OC_NEGATIVE_LOOKAHEAD : swbreak
							default
								errIdx_=left_+2 : return OC_INVALID
						swend
						newmod node_, Node_regExp, oc, strmid(tgt_, left_, len_), 0,0, NULL,NULL
						return oc
					}
					newmod node_, Node_regExp, OC_CAPTURE, strmid(tgt_, left_, len_), 0,0, NULL,NULL
					return OC_CAPTURE
				case '{'
					//�Ή����� } ��T��
					right2=find_close_bracket(tgt_, '}', left_+1, right_, FALSE)
					if (right2==-1) {errIdx_=left_ : return OC_INVALID}
					en_=right2+1-left_
					if (len_<=2) {errIdx_=left_ : return OC_INVALID}	//���g����
					
					oc=parse_in_braces(tgt_, left_+1, right2, n,m, errIdx_)
					if (oc==OC_INVALID) {return OC_INVALID}
					newmod node_, Node_regExp, oc, strmid(tgt_, left_, len_), n,m, NULL,NULL
					return oc
				case '['
					//�Ή����� ] ��T��
					right2=find_close_bracket(tgt_, ']', left_+1, right_, TRUE)
					if (right2==-1) {errIdx_=left_ : return OC_INVALID}
					len_=right2+1-left_
					if (len_<=2) {errIdx_=left_ : return OC_INVALID}	//���g����
					
					oc=parse_in_boxBrackets(tgt_, left_+1, right2, strbuf, errIdx_)
					if (oc==OC_INVALID) {return OC_INVALID}
					newmod node_, Node_regExp, oc, strbuf, 0,0, NULL, NULL
					return oc
				case '\\'
					//\ �̉E����łȂ����Ƃ� get_one_simplifiable_string() �ɂ��ۏ؂���Ă���
					//�Ȗ񉻕s�\�A�܂萧��\���ł��邱�Ƃ͕ۏ؂���Ă���
					
					char=peek(tgt_, left_+1)
					switch char
						case 'w' : oc=OC_ANY_ENG_LET : strbuf="w" : swbreak
						case 'W' : oc=OC_NOT_ENG_LET : strbuf="W" : swbreak
						case 's' : oc=OC_ANY_SPACE : strbuf="s" : swbreak
						case 'S' : oc=OC_NOT_SPACE : strbuf="S" : swbreak
						case 'd' : oc=OC_ANY_DIGIT : strbuf="d" : swbreak
						case 'D' : oc=OC_NOT_DIGIT : strbuf="D" : swbreak
						case 'b' : oc=OC_BOUND : strbuf="b" : swbreak
						case 'B' : oc=OC_NOT_BOUND : strbuf="B" : swbreak
						default : assertEx (FALSE)
					swend
					len_=2
					newmod node_, Node_regExp, oc, strbuf, 0,0, NULL,NULL
					return oc
				case '.'
					len_=1 : newmod node_, Node_regExp, OC_ANY, ".", 0,0, NULL,NULL
					return OC_ANY
				case '^'
					len_=1 : newmod node_, Node_regExp, OC_LINEHEAD, "^", 0,0, NULL,NULL
					return OC_LINEHEAD
				case '$'
					len_=1 : newmod node_, Node_regExp, OC_LINEEND, "$", 0,0, NULL,NULL
					return OC_LINEEND
				case '|'
					if (left_==right_-1) {errIdx_=left_ : return OC_INVALID}	//�E����
					len_=1 : newmod node_, Node_regExp, OC_OR, "|", 0,0, NULL,NULL
					return OC_OR
				case '?'
					len_=1 : newmod node_, Node_regExp, OC_ZERO_OR_ONE, "?", 0,0, NULL,NULL
					return OC_ZERO_OR_ONE
				case '*'
					if (left_==right_-1) {
						oc=OC_ZERO_OR_MORE_GREEDY : len_=1  : strbuf="*"
					} else {
						char=peek(tgt_, left_+1)
						if (char=='?') {
							oc=OC_ZERO_OR_MORE : len_=2 : strbuf="*?"
						} else {oc=OC_ZERO_OR_MORE_GREEDY : len_=1 : strbuf="*"}
					}
					newmod node_, Node_regExp, oc, strbuf, 0,0, NULL,NULL
					return oc
				case '+'
					if (left_==right_-1) {
						oc=OC_ONE_OR_MORE_GREEDY : len_=1 : strbuf="+"
					} else {
						char=peek(tgt_, left_+1)
						if (char=='?') {
							oc=OC_ONE_OR_MORE : len_=2 : strbuf="+?"
						} else {oc=OC_ONE_OR_MORE_GREEDY : len_=1 : strbuf="+"}
					}
					newmod node_, Node_regExp, oc, strbuf, 0,0, NULL,NULL
					return oc
				default
					errIdx_=left_ : return OC_INVALID
			swend
		
		assert (FALSE)
		return
	
	#deffunc local delete_tree_ int addr_, local addr_left, local addr_right	//delete_tree ����Ă΂��ċA�֐�
		/*
			addr_ : �m�[�h�̃A�h���X�B���̃m�[�h�ȉ���j������
		*/
		assertEx (varuse(tree(addr_)))
		
		addr_left=get_addr_left@Node_regExp(tree(addr_))
		addr_right=get_addr_right@Node_regExp(tree(addr_))
		if (addr_left!=NULL) {delete_tree_ addr_left}
		if (addr_right!=NULL) {delete_tree_ addr_right}
		delmod tree(addr_)
		return
		
	#deffunc local delete_tree	//�\���؂�j��
		if (addr_root==NULL) {return}
		if (vartype(tree)!=VARTYPE_MODULE) {return}
		if (varuse(tree(addr_root))==FALSE) {return}
		delete_tree_ addr_root
		return
	
	#defcfunc local build_tree var tgt_, int left_, int right_, var errIdx_, local oc1, local oc2, local oc3, local len1, local len2, local len3, local node1, local node2, local node3, local left, local right, local addr_left, local addr_right, local strbuf	//�\���؍쐬�BregExp_setPat() ����Ă΂��ċA�֐�
		/*
			tgt_ : ���K�\���p�^�[���S��(�ϐ�)
			left_, right_ : ��͊J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
			errIdx_ : (�\���G���[�̂Ƃ�)�G���[�����ʒu��ۑ�
			
			[�߂�l]
				���s�����Ƃ�(�\���G���[)�� NULL�B
				���������Ƃ��� tgt_ �� ���I�y�����h+���Z�q+�E�I�y�����h �ɕ��������Ƃ��̉��Z�q�m�[�h�̃A�h���X�B
				��,�E�I�y�����h�͋�ɂȂ邱�Ƃ�����B
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<right_))
		assertEx (right_<=strlen(tgt_))
		assertEx (is_valid_sjis_string(tgt_, left_, right_))
		
		oc1=get_one_oc(tgt_, left_, right_, len1, node1, errIdx_) : if (oc1==OC_INVALID) {return NULL}	//1�ڂ̃I�y�R�[�h
		
		//���I�y�����h�K�{�̉��Z�q�Ȃ�G���[
		if (dont_need_left_operand(oc1)==FALSE) {
			errIdx_=left_ : return NULL
		}
		
		if (left_+len1==right_) {	//oc1���E�ɃI�y�R�[�h������
			//���g���t�m�[�h�ɂȂ�p�^�[��
			if (is_simplifiable(tgt_, left_, right_)) {
				newmod tree, Node_regExp, OC_SIMPLE, simplify(tgt_, left_, right_), 0,0, NULL,NULL
				return stat
			}
			if (dont_need_left_operand(oc1)) {
				switch oc1
					case OC_PACK
						return build_tree(tgt_, left_+3, right_-1, errIdx_)
					case OC_POSITIVE_LOOKAHEAD
						addr_left=build_tree(tgt_, left_+3, right_-1, errIdx_)
						if (addr_left==NULL) {return NULL}
						newmod tree, Node_regExp, oc1, "(?=)", 0,0, addr_left,NULL
						return stat
					case OC_NEGATIVE_LOOKAHEAD
						addr_left=build_tree(tgt_, left_+3, right_-1, errIdx_)
						if (addr_left==NULL) {return NULL}
						newmod tree, Node_regExp, oc1, "(?!)", 0,0, addr_left,NULL
						return stat
					case OC_CAPTURE
						addr_left=build_tree(tgt_, left_+1, right_-1, errIdx_)
						if (addr_left==NULL) {return NULL}
						newmod tree, Node_regExp, oc1, "()", 0,0, addr_left,NULL
						return stat
					default
						newmod tree, Node_regExp, oc1, get_string@Node_regExp(node1), 0,0, NULL,NULL
						return stat
				swend
				assertEx (FALSE)
			}
			assertEx (FALSE)
		} else {
			left=left_+len1
			oc2=get_one_oc(tgt_, left, right_, len2, node2, errIdx_) :  : if (oc2==OC_INVALID) {return NULL}	//2�ڂ̃I�y�R�[�h
			
			//(���̎��_�� oc2!=OC_LINEHEAD ������)
			
			//���g���A�����Z�q�ɂȂ�p�^�[��
			if (dont_need_left_operand(oc2)) {
				addr_left=build_tree(tgt_, left_, left, errIdx_) : if (addr_left==NULL) {return NULL}
				addr_right=build_tree(tgt_, left, right_, errIdx_) : if (addr_right==NULL) {delete_tree_ addr_left : return NULL}
				newmod tree, Node_regExp, OC_JOIN, "<->", 0,0, addr_left,addr_right
				return stat
			}
			
			//oc2 �����Z�q�ɂȂ�p�^�[��(���̎��_�� oc2 �͍��I�y�����h�K�{�Ɗm��)
			addr_left=build_tree(tgt_, left_, left, errIdx_) : if (addr_left==NULL) {return NULL}
			if (left+len2==right_) {	//oc2 ���E�ɃI�y�R�[�h������
				addr_right=NULL
			} else {
				addr_right=build_tree(tgt_, left+len2, right_, errIdx_)
				if (addr_right==NULL) {delete_tree_ addr_left : return NULL}
			}
			newmod tree, Node_regExp, oc2, get_string@Node_regExp(node2), get_n@Node_regExp(node2), get_m@Node_regExp(node2), addr_left, addr_right
			return stat
		}
		assertEx (FALSE)
	
	#deffunc local show_tree_ int addr_, int depth_, local thisnode, local addr_left, local addr_right, local strbuf	//show_tree ����Ă΂��ċA�֐�
		/*
			addr_ : �m�[�h�̃A�h���X�B���̃m�[�h�ȉ���\������
			depth_ : �m�[�h�̐[��
		*/
		assertEx (varuse(tree(addr_)))
		dup thisnode, tree(addr_)
		
		//���g�� string ��\��
		strbuf="" : repeat depth_ : strbuf+="  " : loop
		mes strbuf+get_string@Node_regExp(thisnode)
		
		//�q�m�[�h��\��
		addr_left=get_addr_left@Node_regExp(thisnode)
		addr_right=get_addr_right@Node_regExp(thisnode)
		if (addr_left!=NULL) {show_tree_ addr_left, depth_+1}
		if (addr_right!=NULL) {show_tree_ addr_right, depth_+1}
		return
	
	#deffunc local show_tree	//(�f�o�b�O�p)�\���؂̑S�̑���\��
		assertEx (vartype(tree)==VARTYPE_MODULE)
		assertEx (varuse(tree(addr_root)))
		show_tree_ addr_root, 0
		return
		
	#defcfunc regExp_setPat str pat_, var errIdx_, local pat	//�p�^�[�����Z�b�g
		/*
			pat_ : �p�^�[��������
			errIdx_ : (�\���G���[�̂Ƃ�)�G���[���������ʒu��ۑ�
			
			[�߂�l]
				(TRUE,FALSE) : (����,�\���G���[)
		*/
		if (strlen(pat_)==0) {errIdx_=0 : return FALSE}
		
		delete_tree	//�|��
		pat=pat_
		if (is_valid_sjis_string(pat, 0, strlen(pat))==FALSE) {errIdx_=strlen(pat)-1 : return FALSE}
		addr_root=build_tree(pat, 0, strlen(pat), errIdx_)
		return (addr_root!=NULL)
	
	#defcfunc local tree_exists	//�\���؂��\�z�ς݂��H
		if (vartype(tree)!=VARTYPE_MODULE) {return FALSE}
		if (varuse(tree(addr_root))) {return TRUE}
		return FALSE
	
	#defcfunc local match_ var tgt_, int left_, int right_, int addr_, var capt_info_, local thisnode, local oc, local strbuf, local char, local addr_left, local addr_right, local len_match_left, local len_match_right, local len_match, local left, local best_record_left2, local best_record_len_match_right, local count_match	//regExp_match() ����Ă΂��ċA�֐�
		/*
			tgt_ : �^�[�Q�b�g������S��
			left_, right_ : ����J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
			addr_ : �\���؂̃m�[�h�̃A�h���X
			capt_info_ : Capt_info �^���W���[���ϐ��B���������ēn�����ƁB
			
			[����]
				addr_ �m�[�h�ȉ��� tgt_ �� left_ �̈ʒu�Ń}�b�`���邩�ǂ������ׂ�
			
			[�߂�l]
				(-1,larger) : (��v�Ȃ�, ��v��������)
		*/
		assertEx ((left_>=0)&&(right_>=0)&&(left_<=right_))	//�s���� $ �I�y���[�^�ɑ΂��Ă� left_==right_ �ƂȂ蓾��
		assertEx (right_<=strlen(tgt_))
		
		dup thisnode, tree(addr_)
		oc=get_oc@Node_regExp(thisnode)
		assertEx (oc!=OC_INVALID)
		
		//���g���t�m�[�h�ł���p�^�[��
			switch oc
				case OC_SIMPLE
					if (left_==right_) {return -1}
					strbuf=get_string@Node_regExp(thisnode)
					if (strlen(strbuf)>right_-left_) {return -1}
					if (0==instr(tgt_, left_, strbuf)) {return strlen(strbuf)}
					return -1
				case OC_ANY_ENG_LET
					if (left_==right_) {return -1}
					if (is_eng_letter(peek(tgt_, left_))) {return 1}
					return -1
				case OC_NOT_ENG_LET
					if (left_==right_) {return -1}
					if (is_eng_letter(peek(tgt_, left_))) {return -1}
					return 1
				case OC_ANY_SPACE
					if (left_==right_) {return -1}
					if (is_space(peek(tgt_, left_))) {return 1}
					return -1
				case OC_NOT_SPACE
					if (left_==right_) {return -1}
					if (is_space(peek(tgt_, left_))) {return -1}
					return 1
				case OC_ANY_DIGIT
					if (left_==right_) {return -1}
					if (is_number(peek(tgt_, left_))) {return 1}
					return -1
				case OC_NOT_DIGIT
					if (left_==right_) {return -1}
					if (is_number(peek(tgt_, left_))) {return -1}
					return 1
				case OC_BOUND
					if (left_==right_) {return 0}
					if (is_space(peek(tgt_, left_))) {return 1}
					return -1
				case OC_NOT_BOUND
					if (left_==right_) {return -1}
					if (is_space(peek(tgt_, left_))) {return -1}
					return 1
				case OC_ANY
					if (left_==right_) {return -1}
					if (is_first_byte_of_zenkaku(peek(tgt_, left_))) {return 2}
					return 1
				case OC_LINEHEAD
					if (left_==0) {return 0}
					if (peek(tgt_, left_-1)==10) {return 0}
					return -1
				case OC_LINEEND
					if (left_==right_) {return 0}
					char=peek(tgt_, left_)
					if ((char=='\r')||(char==10)) {return 0}
					return -1
				case OC_SET
					if (left_==right_) {return -1}
					if (is_char_in_set@Node_regExp(thisnode, peek(tgt_, left_))) {return 1}
					return -1
				case OC_ANTI_SET
					if (left_==right_) {return -1}
					if (is_char_in_set@Node_regExp(thisnode, peek(tgt_, left_))) {return -1}
					return 1
			swend
		
		//���m�[�h�����p�^�[��
			addr_left=get_addr_left@Node_regExp(thisnode) : assertEx (addr_left!=NULL)
			addr_right=get_addr_right@Node_regExp(thisnode)
			
			if (oc==OC_JOIN) {
				assertEx (addr_right!=NULL)
				len_match_left=match_(tgt_, left_, right_, addr_left, capt_info_)
				if (len_match_left==-1) {return -1}
				len_match_right=match_(tgt_, left_+len_match_left, right_, addr_right, capt_info_)
				if (len_match_right==-1) {return -1}
				return len_match_left+len_match_right
			}
			if (oc==OC_OR) {
				assertEx (addr_right!=NULL)
				len_match_left=match_(tgt_, left_, right_, addr_left, capt_info_)
				len_match_right=match_(tgt_, left_, right_, addr_right, capt_info_)
				assertEx ((left_+len_match_left<right_)&&(left_+len_match_right<right_))
				if ((len_match_left==-1)&&(len_match_right==-1)) {return -1}
				if (len_match_left>len_match_right) {return len_match_left}
				return len_match_right
			}
			if (oc==OC_ZERO_OR_ONE) {
				/*
					tgt_="a"
					pattern=".?a"
					
					�̂悤�ȕa���I�ȃP�[�X�ɂ��Ώ����Ȃ΂Ȃ��
				*/
				len_match_left=limit(match_(tgt_, left_, right_, addr_left, capt_info_), 0)
				assertEx (left_+len_match_left<=right_)
				
				if (addr_right==NULL) {return len_match_left}
				len_match_right=match_(tgt_, left_+len_match_left, right_, addr_right, capt_info_)
				if (len_match_right==-1) {
					len_match_right=match_(tgt_, left_, right_, addr_right, capt_info_)	//���I�y�����h�𖳎����Ă�����x����
					if (len_match_right>=0) {return len_match_right}
					return -1
				}
				assertEx (left_+len_match_left+len_match_right<=right_)
				return len_match_left+len_match_right
			}
			if ((oc==OC_ZERO_OR_MORE)||(oc==OC_ONE_OR_MORE)) {
				/*
					tgt_="a"
					pattern=".*?a"
					
					�̂悤�ȕa���I�ȃP�[�X�ɂ��Ώ����Ȃ΂Ȃ��
				*/
				//OC_ZERO_OR_MORE �ɂ��Ă͍��I�y�����h�����Ŏ���
				if (oc==OC_ZERO_OR_MORE) {
					if (addr_right==NULL) {return 0}	//��������ł���
					len_match_right=match_(tgt_, left_, right_, addr_right, capt_info_)
					if (len_match_right>=0) {return len_match_right}	//��������ł���
				}
				
				left=left_
				repeat
					if (left==right_) {len_match=-1 : break}
					
					len_match_left=match_(tgt_, left, right_, addr_left, capt_info_)
					assertEx (left+len_match_left<=right_)
					
					if (len_match_left>=0) {
						if (addr_right!=NULL) {
							len_match_right=match_(tgt_, left+len_match_left, right_, addr_right, capt_info_)
							assertEx (left+len_match_left+len_match_right<=right_)
							if (len_match_right>=0) {
								len_match=left+len_match_left+len_match_right-left_
								break
							} else {
								left+=limit(len_match_left,1)	//^*?hoge �ւ̑Ώ�
								continue
							}
						} else {
							len_match=left+len_match_left-left_
							break
						}
					} else {
						if (addr_right!=NULL) {
							len_match=-1
							break
						} else {
							len_match=left-left_
							break
						}
					}
				loop
				return len_match
			}
			if ((oc==OC_ZERO_OR_MORE_GREEDY)||(oc==OC_ONE_OR_MORE_GREEDY)) {
				best_record_left2=-1	//�E�I�y�����h���}�b�`�����ʒu�̍ō��L�^
				best_record_len_match_right=-1	//���ɂ������v�̒���
				
				//OC_ZERO_OR_MORE_GREEDY �ɂ��Ă͍��I�y�����h�����Ŏ���
				if (oc==OC_ZERO_OR_MORE_GREEDY) {
					if (addr_right==NULL) {
						best_record_left2=left_ : best_record_len_match_right=0
					} else {
						len_match_right=match_(tgt_, left_, right_, addr_right, capt_info_)
						if (len_match_right>=0) {
							best_record_left2=left_ : best_record_len_match_right=len_match_right
						}
					}
				}
				
				left=left_
				repeat
					if (left==right_) {break}
					len_match_left=match_(tgt_, left, right_, addr_left, capt_info_)
					assertEx (left+len_match_left<=right_)
					
					if (len_match_left>=0) {
						if (addr_right!=NULL) {
							len_match_right=match_(tgt_, left+len_match_left, right_, addr_right, capt_info_)
							assertEx (left+len_match_left+len_match_right<=right_)
							if (len_match_right>=0) {
								best_record_left2=left+len_match_left
								best_record_len_match_right=len_match_right
							}
							left+=limit(len_match_left,1)	//^*hoge �ւ̑Ώ�
							continue
						} else {
							best_record_left2=left+len_match_left
							best_record_len_match_right=0
							left+=limit(len_match_left,1)	//^*hoge �ւ̑Ώ�
							continue
						}
					} else {
						if (addr_right!=NULL) {
							break
						} else {
							best_record_left2=left
							best_record_len_match_right=0
							break
						}
					}
				loop
				if (best_record_left2==-1) {return -1}
				return best_record_left2+best_record_len_match_right-left_
			}
			if ((oc==OC_N)||(oc==OC_N_)||(oc==OC_NM)) {
				//���I�y�����h�̌J��Ԃ��񐔂̃`�F�b�N
				left=left_
				count_match=0	//�}�b�`������
				len_match=0	//�}�b�`���������̗ݐ�
				repeat
					if (left==right_) {break}
					
					len_match_left=match_(tgt_, left, right_, addr_left, capt_info_)
					assertEx (left+len_match_left<=right_)
					
					if (len_match_left>=0) {
						count_match++ : len_match+=len_match_left
						left+=len_match_left
						continue
					} else {break}
				loop
				
				switch oc
					case OC_N : if (count_match!=get_n@Node_regExp(thisnode)) {return -1} : swbreak
					case OC_N_ : if (count_match<get_n@Node_regExp(thisnode)) {return -1} : swbreak
					case OC_NM : if ((count_match<get_n@Node_regExp(thisnode))||(count_match>get_m@Node_regExp(thisnode))) {return -1} : swbreak
					default
						assertEx (FALSE)
				swend
				assertEx (left_+len_match<=right_)
				
				//�E�I�y�����h�̃`�F�b�N
				if (addr_right==NULL) {return len_match}
				len_match_right=match_(tgt_, left_+len_match, right_, addr_right, capt_info_)
				if (len_match_right==-1) {return -1}
				assertEx (left_+len_match+len_match_right<=right_)
				
				return len_match+len_match_right
			}
			if (oc==OC_POSITIVE_LOOKAHEAD) {
				len_match_left=match_(tgt_, left_, right_, addr_left, capt_info_)
				assertEx (left_+len_match_left<=right_)
				return limit(len_match_left, -1,0)
			}
			if (oc==OC_NEGATIVE_LOOKAHEAD) {
				len_match_left=match_(tgt_, left_, right_, addr_left, capt_info_)
				assertEx (left_+len_match_left<=right_)
				if (len_match_left==-1) {return 0}
				return -1
			}
			if (oc==OC_CAPTURE) {
				len_match_left=match_(tgt_, left_, right_, addr_left, capt_info_)
				assertEx (left_+len_match_left<=right_)
				if (len_match_left==-1) {return -1}
				add@Capt_info_regExp capt_info_, left_, len_match_left
				return len_match_left
			}
		
		assertEx(FALSE)
		return
	
	#defcfunc regExp_search str tgt_, int left_, int right_, int max_match_, array idx_match_, array length_match_, array capt_info_array_, local tgt, local max_match, local count_match, local left, local len_match, local capt_info	//�}�b�`����
		/*
			�o�^�ς݂̃p�^�[�����g���Č���
			
			tgt_ : �^�[�Q�b�g������
			left_, right_ : �����J�n,�I���ʒu(�I���ʒu�͉�͑ΏۂɊ܂܂�Ȃ�)
			max_match_ : ��������ő���B-1���w�肷��� INT_MAX($7FFFFFFF=214783647) �Ƃ��Ĉ���(�����㖳�����ɂȂ�)�B
			idx_match_ : �}�b�`�����C���f�b�N�X��ۑ�����z��
			length_match_ : �}�b�`����������̒�����ۑ�����z��
			capt_info_array_ : �L���v�`�����(Capt_info_regExp ���W���[���ϐ�)��ۑ�����z��
				idx_match_, length_match_, capt_info_array_ ��i�Ԗڗv�f�ɂ�i�ԖڂɃ}�b�`�������̂̏�񂪕ۑ������B
			
			[�߂�l]
				(-2, -1, larger) : (�p�^�[�����o�^, �����s��, �}�b�`������)
			
		*/
		if (tree_exists()==FALSE) {return -2}
		if ((left_<0)||(right_<0)||(left_>right_)) {return -1}
		if (left_==right_) {return 0}
		if (right_>strlen(tgt_)) {return -1}
		if (max_match_<-1) {return -1}
		
		clear_mod_var_array capt_info_array_
		
		tgt=tgt_
		if (max_match_==-1) {max_match=$7FFFFFFF} else {max_match=max_match_}
		left=left_ : count_match=0
		repeat
			if ((left==right_)||(count_match==max_match)) {break}
			
			newmod capt_info_array_, Capt_info_regExp
			len_match=match_(tgt, left, right_, addr_root, capt_info_array_(count_match))
			assertEx (left+len_match<=right_)
			
			if (len_match>=0) {
				idx_match_(count_match)=left : length_match_(count_match)=len_match
				count_match++
				left+=limit(len_match,1)
				continue
			}
			delmod capt_info_array_(count_match)
			if (is_first_byte_of_zenkaku(peek(tgt, left))) {left+=2} else {left++}
		loop
		
		return count_match
	
	#defcfunc regExp_match str tgt_, var capt_info_, local tgt, local len_match	//�ȈՃ}�b�`
		/*
			tgt_ : �^�[�Q�b�g������
			capt_info_ : �L���v�`�����(Capt_info_regExp ���W���[���ϐ�)��ۑ�
			
			[�߂�l]
				(-3,-2,-1,1) : (�p�^�[�����o�^, �����s��, �}�b�`���Ȃ�, �}�b�`��������)
		*/
		if (tree_exists()==FALSE) {return -3}
		if (strlen(tgt_)==0) {return -2}
		
		clear_mod_var_array capt_info_
		
		tgt=tgt_
		newmod capt_info_, Capt_info_regExp
		len_match=match_(tgt, 0, strlen(tgt), addr_root, capt_info_)
		assertEx (len_match<=strlen(tgt))
		
		if (len_match>=0) {return len_match}
		return -1
#global

init@mod_regExp

//��Еt��
	#undef DEBUGMODE
	#undef assertEx
	
	#undef TRUE
	#undef FALSE
	#undef NULL
	
	#undef VARTYPE_MODULE

	#undef OC_INVALID
	#undef OC_SIMPLE
	#undef OC_ANY_ENG_LET
	#undef OC_NOT_ENG_LET
	#undef OC_ANY_SPACE
	#undef OC_NOT_SPACE
	#undef OC_ANY_DIGIT
	#undef OC_NOT_DIGIT
	#undef OC_ANY
	#undef OC_BOUND
	#undef OC_NOT_BOUND
	#undef OC_LINEHEAD
	#undef OC_LINEEND
	#undef OC_JOIN
	#undef OC_OR
	#undef OC_ZERO_OR_ONE
	#undef OC_ZERO_OR_MORE
	#undef OC_ZERO_OR_MORE_GREEDY
	#undef OC_ONE_OR_MORE
	#undef OC_ONE_OR_MORE_GREEDY
	#undef OC_N
	#undef OC_N_
	#undef OC_NM
	#undef OC_SET
	#undef OC_ANTI_SET
	#undef OC_PACK
	#undef OC_POSITIVE_LOOKAHEAD
	#undef OC_NEGATIVE_LOOKAHEAD
	#undef OC_CAPTURE
	#undef OC_DUMMY