#include<iostream>
#include<vector>
#include<string>
#include<fstream>
using namespace std;

string dec2bin(string imm, int bit)  // turn to a binary string with "bit" bits
{
	int imm_dec = 0;
	int exp = 1;
	string imm_bin;
	for (int i = int(imm.size()) - 1; i >= 0; i--)
	{
		imm_dec += int(imm[i] - '0')*exp;
		exp *= 10;
	}
	for (int i = bit - 1; i >= 0; i--)
		imm_bin += (imm_dec & (1 << i)) ? "1" : "0";
	return imm_bin;
}
string Regtrans(string reg)
{
	if (reg == "$zero" || reg == "$0")		return "00000";
	if (reg == "$at" || reg == "$1")			return "00001";
	if (reg == "$v0" || reg == "$2")			return "00010";
	if (reg == "$v1" || reg == "$3")			return "00011";
	if (reg == "$a0" || reg == "$4")			return "00100";
	if (reg == "$a1" || reg == "$5")			return "00101";
	if (reg == "$a2" || reg == "$6")			return "00110";
	if (reg == "$a3" || reg == "$7")			return "00111";
	if (reg == "$t0" || reg == "$8")			return "01000";
	if (reg == "$t1" || reg == "$9")			return "01001";
	if (reg == "$t2" || reg == "$10")		return "01010";
	if (reg == "$t3" || reg == "$11")		return "01011";
	if (reg == "$t4" || reg == "$12")		return "01100";
	if (reg == "$t5" || reg == "$13")		return "01101";
	if (reg == "$t6" || reg == "$14")		return "01110";
	if (reg == "$t7" || reg == "$15")		return "01111";
	if (reg == "$s0" || reg == "$16")		return "10000";
	if (reg == "$s1" || reg == "$17")		return "10001";
	if (reg == "$s2" || reg == "$18")		return "10010";
	if (reg == "$s3" || reg == "$19")		return "10011";
	if (reg == "$s4" || reg == "$20")		return "10100";
	if (reg == "$s5" || reg == "$21")		return "10101";
	if (reg == "$s6" || reg == "$22")		return "10110";
	if (reg == "$s7" || reg == "$23")		return "10111";
	if (reg == "$t8" || reg == "$24")		return "11000";
	if (reg == "$t9" || reg == "$25")		return "11001";
	if (reg == "$k0" || reg == "$26")		return "11010";
	if (reg == "$k1" || reg == "$27")		return "11011";
	if (reg == "$gp" || reg == "$28")		return "11100";
	if (reg == "$sp" || reg == "$29")		return "11101";
	if (reg == "$fp" || reg == "$30")		return "11110";
	if (reg == "$ra" || reg == "$31")		return "11111";
	return "error";
}
string Funtrans(string op)
{
	if (op == "add")	return "100000";
	if (op == "addu")	return "100001";
	if (op == "sub")	return "100010";
	if (op == "subu")	return "100011";
	if (op == "and")	return "100100";
	if (op == "or")		return "100101";
	if (op == "xor")	return "100110";
	if (op == "nor")	return "100111";
	if (op == "sll")		return "000000";
	if (op == "srl")		return "000010";
	if (op == "sra")		return "000011";
	if (op == "slt")		return "101010";
	return "error";
}
class Instruction {
public:
	char type;
	int num;
	string label, op, content;
	string machinecode;
	Instruction(string label, string op, string content, int num)
	{
		this->num = num;
		this->label = label;
		this->op = op;
		this->content = content;
	}
	void classify();
	void translate();
};
vector<Instruction> instr;	// set a global variable instr
void Instruction::classify()
{
	if (op == "nop") type = 'N';
	else if (op == "j" || op == "jal") type = 'J';
	else if (op == "add" || op == "addu" || op == "sub" || op == "subu" || op == "and" || op == "or" || op == "xor" ||
		op == "nor" || op == "sll" || op == "srl" || op == "sra" || op == "slt" || op == "jr" || op == "jalr") type = 'R';
	else if (op == "addi" || op == "addiu" || op == "andi" || op == "slti" || op == "sltiu" || op == "lw" || op == "sw" ||
		op == "lui" || op == "beq" || op == "bne" || op == "blez" || op == "bgtz" || op == "bltz") type = 'I';
}
string offset(vector<Instruction> v, int num, string label, int bit)
{
	int off = 0;
	string out;
	for (int i = 0; i<int(v.size()); i++)
		if (v[i].label == label) { off = v[i].num - num - 1; break; }
	for (int i = bit - 1; i >= 0; i--)
		out += (off & (1 << i)) ? "1" : "0";
	return out;
}
string joffset(vector<Instruction> v, int num, string label, int bit)
{
	int off = 0;
	string out;
	for (int i = 0; i<int(v.size()); i++)
		if (v[i].label == label) { off = v[i].num; break; }
	for (int i = bit - 1; i >= 0; i--)
		out += (off & (1 << i)) ? "1" : "0";
	return out;
}
void Instruction::translate()
{
	classify();
	if (type == 'N') machinecode = "00000000000000000000000000000000";
	else if (type == 'R')
	{
		string opcode, rs, rt, rd, shamt, funct;
		opcode = "000000";
		if (op == "jr")
		{
			rs = Regtrans(content);
			rt = rd = shamt = "00000";
			funct = "001000";
		}
		else if (op == "jalr")
		{
			int it_rd = content.find(',', 0);
			rs = Regtrans(content.substr(0, it_rd - 1));
			rd = Regtrans(content.substr(it_rd + 1, content.size() - it_rd));
			rt = shamt = "00000";
			funct = "001001";
		}
		else if (op == "sll" || op == "srl" || op == "sra")
		{
			int it_rt = content.find(",", 0);
			int it_shamt = content.find(",", it_rt + 1);
			rs = "00000";		// actually we don't care
			rd = Regtrans(content.substr(0, it_rt));
			rt = Regtrans(content.substr(it_rt + 1, it_shamt - it_rt - 1));
			shamt = dec2bin(content.substr(it_shamt + 1, content.size() - it_shamt - 1), 5);
			funct = Funtrans(op);
		}
		else
		{
			int it_rs = content.find(",", 0);
			int it_rt = content.find(",", it_rs + 1);
			rd = Regtrans(content.substr(0, it_rs));
			rs = Regtrans(content.substr(it_rs + 1, it_rt - it_rs - 1));
			rt = Regtrans(content.substr(it_rt + 1, content.size() - it_rt - 1));
			shamt = "00000";
			funct = Funtrans(op);
		}
		machinecode = opcode + rs + rt + rd + shamt + funct;
	}
	else if (type == 'I')
	{
		string opcode, rs, rt, imm;
		if (op == "lw" || op == "sw" || op == "lui")
		{
			if (op == "lw") opcode = "100011";
			else if (op == "sw") opcode = "101011";
			else opcode = "001111";
			int it_imm = content.find(",", 0);
			int it_rs = content.find("(", 0);
			rt = Regtrans(content.substr(0, it_imm));
			imm = dec2bin(content.substr(it_imm + 1, it_rs - it_imm - 1), 16);
			if (op == "lui") rs = "00000";
			else rs = Regtrans(content.substr(it_rs + 1, content.size() - it_rs - 2));
		}
		else if (op == "beq" || op == "bne")
		{
			opcode = (op == "beq") ? "000100" : "000101";
			int it_rt = content.find(',', 0);
			int it_imm = content.find(',', it_rt + 1);
			rs = Regtrans(content.substr(0, it_rt));
			rt = Regtrans(content.substr(it_rt + 1, it_imm - it_rt - 1));
			if (content[it_imm]>'0'&&content[it_imm]<'9')		// if branch is given as a number
				imm = dec2bin(content.substr(it_imm + 1, content.size() - it_imm), 16);
			else		// if branch is given as a label
				imm = offset(instr, num, content.substr(it_imm + 1, content.size() - it_imm), 16);
		}
		else if (op == "bgtz" || op == "bltz" || op == "blez")
		{
			if (op == "bgtz") opcode = "000111";
			else if (op == "bltz") opcode = "000001";
			else opcode = "000110";
			int it_imm = content.find(',', 0);
			rs = Regtrans(content.substr(0, it_imm));
			rt = "00000";
			if (content[it_imm]>'0'&&content[it_imm]<'9')		// if branch is given as a number
				imm = dec2bin(content.substr(it_imm + 1, content.size() - it_imm), 16);
			else		// if branch is given as a label
				imm = offset(instr, num, content.substr(it_imm + 1, content.size() - it_imm), 16);
		}
		else
		{
			if (op == "addi") opcode = "001000";
			else if (op == "addiu") opcode = "001001";
			else if (op == "slti") opcode = "001010";
			else if (op == "sltiu") opcode = "001011";
			else if (op == "andi") opcode = "001100";
			int it_rs = content.find(',', 0);
			int it_imm = content.find(',', it_rs + 1);
			rt = Regtrans(content.substr(0, it_rs));
			rs = Regtrans(content.substr(it_rs + 1, it_imm - it_rs - 1));
			imm = dec2bin(content.substr(it_imm + 1, content.size() - it_imm), 16);
		}
		machinecode = opcode + rs + rt + imm;
	}
	else if (type = 'J')
	{
		string opcode, target;
		opcode = (op == "j") ? "000010" : "000011";
		if (content[0]>'0'&&content[0]<'9')
			target = dec2bin(content, 26);
		else target = joffset(instr, num, content, 26);
		machinecode = opcode + target;
	}
}
int main()
{
	int n = 0;
	ifstream ifile("MIPScode.txt");
	ofstream ofile("Machinecode.txt");
	string temp, label, op, content;
	while (getline(ifile, temp))
	{
		int it_label = temp.find(':', 0);
		int it_op = temp.find(' ', it_label + 2);
		int it_content = temp.find(' ', it_op);
		if (it_label != -1) label = temp.substr(0, it_label);
		else label = "nolabel";
		op = temp.substr(it_label + 2, it_op - it_label - 2);
		content = temp.substr(it_content + 1, temp.size() - it_content - 1);
		instr.push_back(Instruction(label, op, content, n));
		n++;
	}
	for (int i = 0; i<int(instr.size()); i++)
	{
		instr[i].translate();
		ofile << "ROMDATA[" << i << "] <= 32'b" << instr[i].machinecode << ";\n";
		cout << "ROMDATA[" << i << "] <= 32'b" << instr[i].machinecode << ";\n";
	}
	ifile.close();
	ofile.close();
	return 0;
}
