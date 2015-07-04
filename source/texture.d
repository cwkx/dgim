// Copyright 2015 Chris G. Willcocks
// License: GNU General Public License Version 3

module texture;

import derelict.opengl3.gl3;
import kernel;
import std.stdio,std.random;

class Texture(Type)
{
	// cpu data
	uint N = 2;
	uint C = 4;
	uint[] size;
	Type[] data;

	// gpu handle
	GLuint id;

	this(string filename = "")
	{
		size = [512,512];
		data = new Type[512*512*C];

		glGenTextures(1, &id);

		if (N == 2)
		{
			glBindTexture(GL_TEXTURE_2D, id);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, GL_MIRRORED_REPEAT);
		}
	}

	~this()
	{
	}

	void upload()
	{
		if (N == 2)
		{
			glBindTexture(GL_TEXTURE_2D, id);
			glTexImage2D(GL_TEXTURE_2D, 0,
				GL_RGBA32F,
				size[0], size[1],
				0,
				GL_RGBA,
				GL_FLOAT,
				&data[0]);
		}

		Kernel.checkErrors("texture upload");
	}
}