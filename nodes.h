#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <sstream>
#include <string>


extern int errorcount;
extern int yylineno;
extern char *build_file_name;

using namespace std;

class Node {
protected:
    vector<Node*> children;
    int lineno;

public:
    Node(){
        lineno = yylineno; 
    }
    int getLineNo(){
        return lineno;
    }
      virtual string getType()
    {
        return " ";
    }
    virtual string toStr() {
        return "stmts";
    }

    void append(Node *n) {
        children.push_back(n);
    }
    vector<Node*>& getChildren(){
        return children;
    }
};

class Program : public Node {
public:
    virtual string toStr() override {
        return "Program";
    }
};

class Integer : public Node {
protected:
    int value;
public:
    Integer(const int v) {
        value = v;
    }

    int getValue(){
        return value;
    }

    virtual string toStr() override {
        return to_string(value);
    }
};

class Float : public Node {
protected:
    float value;
public:
    Float(const float v) {
        value = v;
    }

    virtual string toStr() override {
        return to_string(value);
    }
};

class Ident : public Node {
protected:
    string name;
public:
    Ident(const string n) {
        name = n;
    }

    const string getName() {
        return name;
    }

    virtual string toStr() override {
        return name;
    }
};


class While : public Node
{
protected:
    Node *condition;
    Node *content;

public:
    While(Node *c, Node *n)
    {
        content = n;
        condition = c;
        children.push_back(c);
        children.push_back(n);
    }
    virtual Node *getCondition()
    {
        return condition;
    }

    virtual string toStr() override
    {
        return "While";
    }
};

class Sempreq : public Node
{
protected:
    Node *condition;
    Node *content;

public:
    Sempreq(Node *c, Node *n)
    {
        condition = c;
        content = n;
        children.push_back(c);
        children.push_back(n);
    }

    virtual Node *getCondition() { return condition; }

    virtual string toStr() override
    {
        return "Sempreq";
    }
};


class SempreqQuandon : public Node
{
protected:
    Node *contentSempreq;
    Node *contentQuandon;
    Node *condition;

public:
    SempreqQuandon(Node *c, Node *sq, Node *qn)
    {
        condition = c;
       contentSempreq = sq;
        contentQuandon = qn;
        children.push_back(c);
        children.push_back(sq);
        children.push_back(qn);
    }

    virtual Node *getCondition()
    {
        return condition;
    }
    virtual string toStr() override
    {
        return "Sempreq Quandon";
    }
};

class SempreqQuandonLoop : public Node
{
protected:
    Node *contentSempreq; 
    Node *contentQuandonLoop; 
    Node *condition;

public:
    SempreqQuandonLoop(Node *c, Node *sq, Node *ql)
    {
        condition = c;
        contentSempreq = sq;
        contentQuandonLoop = ql;
        children.push_back(c);
        children.push_back(sq);
        children.push_back(ql);
    }

    virtual Node *getCondition()
    {
        return condition;
    }

    virtual string toStr() override
    {
        return "Sempreq Quandon Loop";
    }
};

class PositivoNegativo : public Node
{
protected:
    bool value;

public:
    PositivoNegativo(const bool v)
    {
        value = v;
    }
    virtual string getType() override
    {
        return "bool";
    }
    virtual bool getValue()
    {
        return value;
    }
    virtual string toStr() override
    {
        if (value)
        {
            return "true";
        }
        else
        {
            return "false";
        }
    }
};





class Variable : public Node {
protected:
    string name;
    Node *value;
public:
    Variable(const string n, Node *v) {
        name = n;
        value = v;
        children.push_back(v);
    }

    const string getName() {
        return name;
    }

    virtual string toStr() override {
        return name + "=";
    

    }
};

class Unary : public Node {
protected:
    Node *value;
    char operation;

public:
    Unary(Node *v, char op) {
        value = v;
        operation = op;
        children.push_back(v);
    }

    virtual string toStr() override {
        string aux;
        aux.push_back(operation);
        return aux;
    }

    
};

class BinaryOp : public Node {
protected:
    Node *value1;
    Node *value2;
    char operation;

public:
    BinaryOp(Node *v1, Node *v2, char op) {
        value1 = v1;
        value2 = v2;
        operation = op;
        children.push_back(v1);
        children.push_back(v2);
    }

    virtual string toStr() override {
        string aux;
        aux.push_back(operation);
        return aux;
    }

    
};


class BinaryOpCompare: public Node {
protected:
    Node *value1;
    Node *value2;
    string operation;

public:
    BinaryOpCompare(Node *v1, Node *v2, string op) {
       value1 = v1;
       value2 = v2;
       operation = op;
       children.push_back(v1);
       children.push_back(v2);
    }

    virtual string toStr() override {
        return operation;
    }

};

class BinaryOpPower : public Node {
protected:
    Node *base;
    Node *exponent;
    char operador;

public:
    BinaryOpPower(Node *b, Node *e, char op) 
        : base(b), exponent(e), operador(op)
        {
        children.push_back(b);
        children.push_back(e);
    }

    Node* getBase() { return base; }
    Node* getExponent() { return exponent; }

    virtual string toStr() override {
        return base->toStr() + "^" + exponent->toStr();
    }
};


class Print : public Node {
protected:
    Node *value;

public:
    Print(Node *v) {
        value = v;
        children.push_back(v);
    }

    virtual string toStr() override {
        return "print";
    }
};

void printf_tree_recursive(Node *noh){
    for(Node *c: noh->getChildren()){
        printf_tree_recursive(c);
    }
    cout << "N" << (long int)noh << "[label=\"" << noh->toStr() << "\"];" << endl;

    //imprime as ligações com os filhos
    for(Node *c: noh->getChildren()){
        cout << "N" << (long int)noh << "--" << "N" << (long int)c << ";" << endl;
    }
}

void printf_tree(Node *root) {
    cout << "graph {" << endl;
    printf_tree_recursive(root);
    cout << "}" << endl;
}



class CheckVarDecl {
private:
    set<string> symbols;
public: 

	CheckVarDecl() {}

    void check(Node *noh) {
        for(Node *c : noh->getChildren()) {
            check(c);
        }

        if (Ident *id = dynamic_cast<Ident*>(noh)) {
            if (symbols.count(id->getName()) <= 0) {
                cout << build_file_name
                     << ":"
                     << id->getLineNo()
                     << ":0: semantico error: "
                     << id->getName()
                     << " recusado."
                     << endl;
                errorcount++;
            }
        }

        if (Variable *var = dynamic_cast<Variable*>(noh)) {
            symbols.insert(var->getName());
        }
    }
};

class CheckVarSize{
  private:
        
  public:
        CheckVarSize() {}

        void check(Node *noh) {
            for(Node *c: noh->getChildren()){
                check(c);
            }
            if(Integer *n = dynamic_cast<Integer*>(noh)){
                if (n->getValue() > 9999)
                {
                    cout << build_file_name
                        << ":"
                        << n->getLineNo()
                        << ":0: semantic error: " 
                        << " Integer is too big"
                        << endl;
                    errorcount++;
                }
                
            }

        }  
};

