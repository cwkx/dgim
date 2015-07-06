// Copyright 2015 Chris G. Willcocks
// License: GNU General Public License Version 3

module kernel;

import gl3n.linalg, derelict.opengl3.gl3;
import std.string, std.stdio;
import texture;

class Kernel
{
	GLuint id;
	string code;

	this(string src)
	{
		code = src;

		id = glCreateProgram();
		GLuint cs = glCreateShader(GL_COMPUTE_SHADER);

		auto ssp = code.ptr;
		int ssl = cast(int)(code.length); 
		glShaderSource(cs, 1, &ssp, &ssl);

		glCompileShader(cs);
		checkErrors("kernel compile", cs, GL_COMPILE_STATUS);
		glAttachShader(id, cs);
		glLinkProgram(id);
		glUseProgram(id);

		checkErrors("compute shader");
	}

	void execute()
	{
		glUseProgram(id);
		//glUniform1f(glGetUniformLocation(id, "roll"), cast(float)(++frame)*0.1f);
		glDispatchCompute(512/16, 512/16, 1); // 512^2 threads in blocks of 16^2

		checkErrors("dispatch compute shader");
	}

	void upload(string location, float x) { glUseProgram(id); glUniform1f(glGetUniformLocation(id, toStringz(location)), x); }
	void upload(string location, vec3  x) { glUseProgram(id); glUniform3f(glGetUniformLocation(id, toStringz(location)), x.x, x.y, x.z); }
	void upload(string location, vec4  x) { glUseProgram(id); glUniform4f(glGetUniformLocation(id, toStringz(location)), x.x, x.y, x.z, x.w); }

	void upload(string location, Texture!(float) t)
	{
		glUseProgram(id);
		//glBindTexture(GL_TEXTURE_2D, t.id);
		// glUniform1i(glGetUniformLocation(id, cast(char*)toStringz(location)), 0); // 0= O'RLY!?
		glBindImageTexture(0, t.id, 0, GL_FALSE, 0, GL_READ_WRITE, GL_RGBA32F); // RGBA32F = O'RLY!?
		checkErrors("upload");
	}

	void checkErrors(string location, GLuint program, GLenum type)
	{
		int status = 0, len = 0;
		glGetShaderiv(program, type, &status);
		if(status==GL_FALSE){
			glGetShaderiv(program, GL_INFO_LOG_LENGTH, &len);
			char[] error=new char[len];
			glGetShaderInfoLog(program, len, null, cast(char*)error);
			writeln(location, " error: ", error);
		}
	}

	static void checkErrors(string location)
	{
		GLenum error = glGetError();
		
		if (error == GL_NO_ERROR) return;
		
		switch(error)
		{
			case GL_INVALID_ENUM :					writeln(location, ": ", "Invalid enum"); break;
			case GL_INVALID_VALUE :					writeln(location, ": ", "Invalid value"); break;
			case GL_INVALID_OPERATION :				writeln(location, ": ", "Invalid operation"); break;
			case 0x0503 : /*GL_STACK_OVERFLOW :*/	writeln(location, ": ", "Stack overflow"); break;
			case 0x0504 : /*GL_STACK_UNDERFLOW :*/	writeln(location, ": ", "Stack underflow"); break;
			case GL_OUT_OF_MEMORY :					writeln(location, ": ", "OpenGL out of memory"); break;
			case GL_INVALID_FRAMEBUFFER_OPERATION : writeln(location, ": ", "Invalid framebuffer operation"); break;
			case GL_CONTEXT_LOST :					writeln(location, ": ", "OpenGL context lost"); break;
			default:								writeln(location, ": ", "Unknown error code: "); break;
		}
	}
}