# README #

CGIM is an experimental high-performance framework for computer graphics and image processing research.

![IMAGE](http://i.imgur.com/cRUk7k7.png)

### Features ###

* N-dimensional image support with C-components
* easily launch GPGPU compute kernels
* easily work with CPU textures
* immediate-mode GUI visualization

### Example Usage ###

```
#!D

// Create two new floating-point CPU texture, fill them with random data, upload to GPU..
Texture!(float) t1 = new Texture!(float)();
				t1.size = [64,64];
				t1.data.length = 64*64*t1.C;
				for (uint i=0; i<t1.data.length; ++i) t1.data[i] = std.random.uniform(0.0f, 1.0f);
				t1.upload();

Texture!(float) t2 = new Texture!(float)();
			t2.data[0..t2.data.length] = 0.2f;
			t2.upload();

// Do some very fast compute work on the GPU, writing to t1...
Kernel k = new Kernel("...");
	   k.upload(t1, "destTex");
	   k.execute();

// Show both images
ig_Image(cast(void*)t1.id, ImVec2(64,64));
ig_Image(cast(void*)t2.id, ImVec2(512,512));
```


### How do I get set up? ###

* Download D compiler (very small) http://dlang.org/download.html
* Download DUB package manager (very smaller) http://code.dlang.org/download
* Make sure both binaries for dmd and dub are in PATH (restart if necessary)
* Download Xamarin Studio (lightweight, free IDE) http://www.monodevelop.com/download/
* In Xamarin, goto Tools > Add-in Manager > Gallery > Refresh > Language Bindings > Install D language bindings
* In Xamarin, open dub.json to load this project!
* Although it should compile, you need to add two dynamic binaries next to executable http://www.glfw.org/download.html and https://github.com/Extrawurst/cimgui


### Todo ###

* test on linux and mac
* port shadertoy params to compute
* fix true N-dimensional textures 1D and 3D cases
* import/output pipeline
* gpu examples tree IMGUI class
* get rid of dynamic binding dependencies, e.g. link directly to C-APIs
* live-script: squirrel or wren
