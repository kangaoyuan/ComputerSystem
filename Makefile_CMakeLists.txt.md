参考资料：[Learn Makefile](https://makefiletutorial.com/#first-functions)、[make and Makefile](https://leehao.me/make%E5%91%BD%E4%BB%A4%E4%B8%8Emakefile%E6%96%87%E4%BB%B6/)、[A Makefile Tutorial](https://www.cprogramming.com/tutorial/makefiles.html)、[Advanced Makefile Techniques](https://www.cprogramming.com/tutorial/makefiles_continued.html)

[toc]

# CMake

CMake 是一个跨平台的编译安装工具，可以使用简单的描述型语句来完成各平台的编译安装过程。如果项目很大，其中有很多源码目录，在通过 CMake 管理项目时，如果只使用一个 CMakeList.txt，这个文件会很大，很复杂。给每个源码目录都添加一个 CMakeList.txt 文件（头文件目录不需要）更灵活，更容易维护。

## 基本语法

1. CMake 使用 `#` 实现行注释，使用 `#[[ ]]` 实现块注释。
2. CMake使用 `message([STATUS|WARNING|FATAL_ERROR] "message to display")` 命令打印消息。

1. CMake 中所有变量的本质都是字符串，不同于 make 使用 `$()` 引用宏，CMake 中使用 `${}` 来引用变量。

2. 常见命令：

   CMakeList.txt 中，每条语句都是一个命令，每个命令都使用字符串列表（空格、或分号分隔）作为参数，并且没有返回值。

   - `cmake_minimum_required` 指定使用 cmake 的最低版本，语法如下：

     ```cmake
     cmake_minimun_required(VERSION x.xx)
     ```

   - `project` 定义工程名称，语法如下：

     ```cmake
     project(<PROJECT-NAME>
     		[VERSION]
     		[DESCRIPTION]
     		[LANGUAGES])
     ```
     
   - `add_subdirectory` 添加子目录，语法如下：

     ```cmake
     # 复杂工程中，需要划分模块，通常一个库一个目录，在子目录中定义 CMakeLists.txt 生成规则
     add_subdirectory(./subdirectory)
     ```

   - `include`  查找并包含 CMAKE_MODULE_PATH 目录下 .cmake 文件，语法如下：

     ```cmake
     # CMAKE_MODULE_PATH 不仅可用于 find_package() 命令查找，也可以用于 include() 命令查找。
     set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "path_to_.cmake")
     # 上条 set() 命令等价于这条 list() 命令
     list(APPEND CMAKE_MODULE_PATH "path_to_.cmake")
     
     # 会在 CMAKE_MODULE_PATH 列表中的所有路径下查找 <CMAKE_FILE>.cmake 文件
     include(<CMAKE_FILE>) 
     # 同 C/C++ 的 #include 预编译指令，可以在 <CMAKE_FILE>.cmake 里写一些常见 CMAKE 的变量、宏、函数
     ```
   
   - `include_directories` 设置生成可执行文件所要包含的头文件目录（会在全局有效，污染项目中所有子目录，因此不推荐）语法如下：
   
     ```cmake
     include_directories(<PATH-TO-HEADER>)
     # CMakeList.txt 实例：
     cmake_minimum_required(VERSION 3.0)
     set(CMAKE_CXX_STANDARD 17)
     project(CALC LANGUAGES CXX)
     
     file(GLOB_RECURSE SRC_LIST CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h)
     add_executable(app ${SRC_LIST})
     # 相对于 target_include_directories 命令,include_directories 命令会强制传递（污染）所有子目录。因此并不是很推荐。
     include_directories(${CMAKE_CURRENT_SOURCE_DIR}include)
     # 不推荐使用 include_directories 命令，推荐使用 target_include_directories 命令
     target_include_directories(<TARGET-NAME> PUBLIC <PATH-TO-DIRECTORIES>)
     # 等价于上面个的 include_directories 命令，不过限制了作用域，但可以 PUBLIC 传播
     target_include_directories(app PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
     ```


   - `add_executable` 定义项目中如何生成可执行文件，语法如下：

     ```cmake
     # 多个源文件间用 空格 或者 ； 隔开
     add_executable(<EXECUTABLE-NAME> <SOURCE-FILES>)
     ```

   - `add_library` 定义项目中如何生成静态、动态库文件，语法如下：

     ```cmake
     # CMake 中生成静态、动态库的命令是同一条命令
     add_library(<LIBRARY-NAME> PUBLIC|PRIVATE <SOURCE_FILES>)
     ```

   > add_library()、add_executable() 命令中指定的 <LIBRARY-NAME\>、<EXECUTABLE-NAME\> 库文件名和可执行文件名，在 CMake 中统一被称为 target 目标

5. 常见宏：

   CMakeList.txt 中可以通过 `set` 命令指定 C++ 标准中用于构建可执行文件的宏，例如：

   ```cmake
   # 指定 -std=c++17
   set(CMAKE_CXX_STANDARD 17)
   
   # 指定可执行文件输出路径，如果指定 <PATH> 不存在，会自动生成
   set(EXECUTABLE_OUTPUT_PATH <PATH>)
   set_property(TARGET <target-name> PROPERTY LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
   
   # 定义宏。相对于 target_add_definition,add_directories 会强制传递（污染）所有子目录。因此并不是很推荐。
   add_definition(-D[MACRO-NAME] VALUE)
   # 推荐使用
   target_add_definitions(<TARGET-NAME> PUBLIC -D<MACRO-NAME>=<VALUE>)
   ```

6. 预定义宏：

   | 宏                       | 功能                                                     |
   | ------------------------ | -------------------------------------------------------- |
   | PROJECT_SOURCE_DIR       | 最近一次调用 project() 命令的 CMakeList.txt 所在源码目录 |
   | PROJECT_BINARY_DIR       | 当前项目输出路径                                         |
   | CMAKE_SOURCE_DIR         | 最外层 CMakelists.txt 所在源码根目录                     |
   | CMAKE_BINARY_DIR         | 根项目输出目录                                           |
   | CMAKE_CURRENT_SOURCE_DIR | 当前 CMakelists.txt 所在源码目录位置                     |
   | CMAKE_CURRENT_BINARY_DIR | 当前输出目录位置                                         |

   `project()` 命令用来初始化项目信息，并把当前 CMakeLists.txt 文件所在位置作为根目录

   利用 PROJECT_SOURCE_DIR 可以实现从子模块里面直接获取项目最外层目录的路径。不建议使用 CMAKE_SOURCE_DIR，因为固定的目录位置，会让项目无法被人作为子模块使用。

   子模块里也可以使用 `project()` 命令，将当前目录作为一个独立的子项目。此时 PROJECT_SOURCE_DIR 就会是子模块的源码目录而不是外层目录。此时 CMAKE 会将该子目录视为独立的项目，并额外进行一些初始化。此时 PROJECT_BINARY_DIR  会变为：root-dir/build/sub-dir

   > 父模块中定义的变量会传递给子模块，但子模块中定义的变量，不会传递给父模块。
   >
   > 可以用 set 命令的 PARENT_SCOPE 选项，把当前模块中定义的变量传递到上一层模块（作用域）即父模块中去。

7. 自定义宏

   - `set` 定义变量，语法如下：

     ```cmake
     # 等价于在 terminal 下，cmake 命令中的 -D 选项定义的变量（-DVAR_NAME=VALUE）
     set(VAR-NAME [VALUE])
     
     set(SRC_LIST send.cpp receive.cpp)
     # ${VAR-NAME} 读取变量内容
     add_executable(app ${SRC_LIST})
     # 使用 set(${VAR} ${VAR1} ${VAR2} ...) 命令拼接字符
     
     target_compile_definitions(<TARGET-NAME> PUBLIC MACRO=VALUE)
     ```

   - `list` 追加、删除变量内容，语法如下：

     ```cmake
     list(APPEND <VAR-NAME> [elements])
     list(REMOVE_ITEM <VAR-NAME> [elements])
     ```

   - `file` 搜索指定目录下符合条件的文件，并将其存储在一个变量中，语法如下：

     ```cmake
     file(GLOB SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
     # 递归搜索
     file(GLOB_RECURSE HEAD ${PROJECT_SOURCE_DIR}/include/*.h)
     # CONFIGURE_DEPENDS 选项，自动更新变量
     file(GLOB_RECURSE SOURCE CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp ${PROJECT_SOURCE_DIR}/include/*.h)
     ```

   - `aux_source_directory` 自动搜索所需文件后缀名，语法如下：

     ```cmake
     # 使用 aux_source_dictory() 命令根据当前项目所使用语言，自动决定要获取哪些后缀名的文件
     aux_source_directory(<SOURCE-DIRECTORY> SOURCE)
     ```

8. 逻辑语句

   流程控制命令包括 `if/endif` 和 `while/endwhile`。`set` 命令和 `if` 命令的第一参数都是不加 \$ 符号的，所以设置 \${x}、${ENV{x}} 就变成了 set(x)、set(ENV{x})，判断当前环境为：if(WIN32) ... endif()

   if 语句的 () 判断逻辑中，变量的取值，不需要添加 ${}，会自动尝试是否有同名变量，并试图求值替换。因此建议不添加 \${}，或者使用 "\${}" 避免递归引用，利用 “” 引号取消元字符的特殊功能。

   > function 和 add_subdirectory 是有独立的作用域。而 macro 和 include 并没有独立的作用域，只是简单的替换、粘贴作用。

9. 寻找，并链接系统中安装的第三方库。

   find_package(<PACKAGE_NAME\> COMPONENTS <components...\> REQUIRED)

   ```cmake
   # 找不到不报错，可以通过 ${<PACKAGE_NAME>_FOUND} 查询
   find_package(<PACKAGE_NAME>)
   ```

   find_package() 命令，实际上再查找名为 <PACKAGE_NAME>Configu.cmake 的文件，这些形如 包名+Config.cmake 文件，被称之为包配置文件。

   系统安装的第三方库，除了 lib<LIBRARY_NAME>.so 等实际的库文件，还有 <PACKAGE_NAME>Config.cmake 等一起安装到系统中的包配置文件。它们分别位于 /usr/lib/lib<LIBRARY_NAME>.so、和 /usr/lib/cmake/<PACKAGE_NAME\>Config.cmake 路径下。

   > find_package() 命令中，可以在 <PACKAGE_NAME\> 后添加版本号，指明最低版本。

   设置 <PACKAGE_NAME\>_DIR 变量的三种方法：

   - configure 阶段，从命令行设置：

     ```cmake
     cmake -B build -D<PAKCKAGE_NAME>_DIR="directory_of_.cmake"
     ```

   - CMakeLists.txt 文件中设置：

     ```cmake
     set(<PACKAGE_NAME>_DIR "directory_of_.cmake")
     ```

   - 设置环境变量：

     ```bash
     export <PACKAGE_NAME>_DIR="directory_of_.cmake"
     ```

   > 只要不删除 build 目录，通过 configure 阶段设置的 <PAKCKAGE_NAME>_DIR 变量，会被记录再 CMakeCache.txt 中。

#### 生成库文件

将一些可复用的函数（功能）打包做成一个库后，库中的函数就可以被其他源文件、或者库文件调用。根据实现手法不同（插入、加载时间不同）库文件可以分为静态、动态库文件。

在链接静态库生成可执行文件时，会直接把静态库的相关代码插入到可执行文件中去，而链接动态库生成的可执行文件中只有插桩函数，当可执行文件执行到动态库文件相关函数时，会读取指定目录中的动态库文件、并替换相应的插桩函数指向已在内存中加载的动态库地址（即重定向）

> Linux  中 ELF 格式的可执行文件，依次搜索 rpath、${PATH} 目录下的动态库文件。插桩函数的跳转动作，即实现跳转到加载到内存中的动态库文件。

- `add_library` 制作静态、动态库命令，语法如下：

  ```cmake
  # 使用 add_library() 命令，可以生成静态、动态库文件
  add_library(<LIBRARY-NAME> <STATIC|SHARED> <SOURCE-FILES>)
  
  # CMakeList.txt 实例：
  cmake_minimum_required(VERSION 3.0)
  project(EXAMPLE)
  
  include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
  file(GLOB SRC_LIST ${CMAKE_CURRENT_SOUrCE_DIR}/src/*.cpp)
  add_library(mylib SHARED ${SRC_LIST})
  
  # 使用 add_library() 命令的语法与 add_executable() 命令的语法大致相同
  add_executable(a.out main.cpp)
  # 使用 target_link_directories() 链接库文件到可执行文件中 
  target_link_directories(a.out PUBLIC mylib)
  ```

- ARCHIVE_OUTPUT_PATH、LIBRARY_OUTPUT_PATH 指定静态\动态输出路径，语法如下：

  ```cmake
  set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)
  ```

> STATIC、SHARED、PUBLIC 等关键字，可以区分文件名，并指定某些选项。
>
> 由于动态库 -fpic，所以无法链接静态库。

#### 包含库文件

- `link_libraries`、`link_directory` 链接静态库、指定静态库路径的命令

  ```cmake
  link_libraries(<STATIC-LIBRARY-NAME>)
  link_directory(<STATIC-LIBRARY-PATH>)
  
  # CMakeList.txt 实例：
  cmake_minimum_required(VERSION 3.0)
  project(CALC)
  include_directories(${PROJECT_SOURCE_DIR}/include)
  file(GLOB SRC_LIST ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
  add_executable(app ${SRC_LIST})
  
  link_directories(${PROJECT_SOURCE_DIR}/lib)
  link_libraries(calc)
  ```

  区别 `link_directories` 命令与 `target_link_directories` 命令，`link_directories(<PATH-TO-LIBRARY>)` 命令指定库文件的搜索路径，而 `target_link_directories(<TARGET-NAME> PUBLIC <LIBRATY-NAME>)` 命令指定 target 目标链接的库文件。

- `target_link_libraries`、`target_include_directories` 指定链接库、指定头文件目录的命令

  `target_include_libraries` 命令指定 target 目标的头文件搜索路径（目录）会被视为与系统路径等价，且使用 `target_include_libraries(<TARGET-NAME> PUBLIC <PATH-TO-HEADER>)` 命令在 target 目标中定义的头文件搜索路径，都会被引用它的目标自动添加。如果不希望这种传递效应，将 PUBLIC 改为 PRIVATE 即可。
  
  ```cmake
  cmake_minmimum_required(VERSION 3.0)
  project(TEST)
  include_directories(${PROJECT_SOURCE_DIR}/include)
  file(GLOB SRC_LIST ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
  link_directories(${PROJECT_SOURCE_DIR}/lib)
  
  # 通过 target_include_directories() 指定的路径会被视为与系统路径等价，可以使用 #include<> 
  add_executable(app ${SRC_LIST})
  target_link_libraries(app pthread calc)
  # 上一条命令的 calc 为库名，下一条命令的 calc 为目录
  target_include_directories(app PUBLIC calc)
  ```
  
  因为只有当可执行文件被启动，且调用了动态库中的函数时，动态库才会被加载到内存。在 CMake 中，指定要链接的动态库时，应该将链接动态库的命令写在生成可执行命令后，且指定加载动态库的文件 \<TARGET\>

> include_directories()、target_include_directories() 的区别在于作用域。include_libraries()、target_include_directories() 的区别在于库文件所在路径、target 目标所需要链接的库文件名称。

## CMake 构建

cmake 可以使用 `add_executable`、`add_library` 或 `add_custom_target` 等命令来定义目标（**target**）可以使用 `get_property` 和 `set_property` 获取或设置目标（**target**）属性：

```cmake
add_executable(test leehao.cpp)

get_property(MYAPP_SOURCES TARGET test PROPERTY SOURCES)

message("${MYAPP_SOURCES}")
```

#### CMake 命令行调用

CMake 作为构建系统的构建系统，通过 `-B <path-to-build>` 选项，指定生成 makefile 所在的目录，如果 <path-to-build\> 该目录不存在，会自动创建。`--build <path-to-makefile>` 选项，指定 make 读取哪个目录下的 makefile，开始构建目标 target。 CMAKE_BINARAY_DIR 即指向该目录。

```bash
# 读取当前目录下的 CMakeList.txt，并在 build 子文件夹下生成 ./build/Makefile
$ cmake -B build -DCMAKE_BUILD_TYPE=Debug
# 让 make 执行 ./build/Makefile，并开始构建 executable 可执行文件
$ make --build build --parallel(-j) 4
$ sudo make --build build --target install

# 与上两条命令等价，但更跨平台
$ mkdir -p build; cd build
$ cmake .. -DCMAKE_BUILD_TYPE=Debug
$ make -j 4
$ sudo make install
```

CMake 除了可以生成 Makefile 外，还可以生成以下 IDE 的编译文件：

- Xcode
- Visual Studio

`cmake` 命令的 -G 选项可以指定生成器，在 -B 选项指定的目录下构建系统。例如：`cmake -GNinja -B build`

install(TARGETS <target_name\> DESTINATION <install_directory\>)、install(File <file_name\> DESTINATION <install_directory\>) 分别用来安装 target 目标、头文件 file 等到指定目录。

> 通过 -D 设置的缓存变量，会被保留

#### 嵌套的 CMakeList.txt

工程根目录中的 `CMakeList.txt` 文件内容，如下：

```cmake
cmake_minimum_required(VERSION 3.0)
project(test)

# 检测编译选项、配置
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSION)
# 定义变量，指示库的生成路径、（测试）可执行程序的生成路径、头文件的搜索路径
set(LIB_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(EXEC_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin）
set(HEAD_PATH ${PROJECT_SOURCE_DIR}/include)

add_subdirectory(calc)
add_subdirectory(sort)
add_subdirectory(test1)
add_subdirectory(test2)
```

工程根目录下的 `CMakeList.txt` 文件中主要做了两件事情：定义全局变量（库、可执行文件路径）和添加子目录（含有 CMakeList.txt 的源码目录）

calc 目录中的 `CMakeList.txt` 文件内容，如下：

```cmake
cmake_minimum_required(VERSION 3.0)
project(calc)
file(GLOB SRC_LIST {CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
# 等价于上条命令：aux_source_directory(./ SRC_LIST)
include_directories(${HEAD_PATH})
set(LIBRARY_OUTPUT_PATH ${LIB_PATH})
add_library(calc SHARED ${SRC_LIST})
```

test1 目录中的 `CMakeList.txt` 文件内容，如下：

```cmake
cmake_minimum_required(VERSION 3.0)
project(test1)
file(GLOB SRC_LIST {CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
# 等价于上条命令：aux_source_directory(./ SRC_LIST)
include_directories(${HEAD_PATH})
set(EXECUTABLE_OUTPUT_PATH ${EXEC_PATH})
add_executable(test1 ${SRC_LIST})
target_link_libraries(test1 calc)
```

## 第三方库

#### 作为头文件引入

作为头文件引入第三方库，只需要把项目的 include 目录或者头文件下载下来，然后在 CMakeList.txt 文件中添加`include_directories(<THIRD- LIBRARY-INLCUDE-PATH>)` 命令即可。使用时需要引入宏定义，避免重复引入同一个头文件。实例：

`ain.cpp` 中调用了 `mandel.cpp` 中的一个函数和 `rainbow.cpp` 中定义的一个函数，而这两个函数又调用了子文件夹 `stbiw` 里的头文件 `stb_image_write.h` 中定义的函数 `stbi_write_png(...)`。而 `stb_image_write.h` 为了方便用户使用，把所有内容都集成到了一个头文件，然后巧妙的用是否定义了 

`STB_IMAGE_WRITE_IMPLEMENTATION` 宏 作为开关来分开头文件中所有的函数声明部分和函数定义部分。这个开关默认是关闭的。所以所有引用了该头文件的 cpp 都只获得了函数的声明，而没有函数的定义。所以解决方案的核心就在于，如何只让这些函数定义只被编译一次（因为如果被编译多次会出现函数重复定义的 LINK 错误）

1. 在 `stbiw` 子文件夹中创建一个 .cpp 文件，在里面打开开关之后，引用头文件。定义该子文件夹的编译规则为，由该 cpp 生成一个静态库，把当前文件夹作为 `include_directories` PUBLC 传播出去。这里，在 cpp 中使用 <> 去引入头文件是更符合设计范式的，同时可以避免引入了用户自定义的同名头文件。

2. 继承方法1，但是通过 flag 来打开开关。在库中创建一个 .cpp 文件，只引入头文件，不打开开关。在 `CMakeLists.txt` 中，使用编译的 flag。但不能使用下面这个：

   ```cmake
   target_compile_definitions(stbiw PUBLIC -DSTB_IMAGE_WRITE_IMPLEMENTATION)
   ```

   是因为这个 PUBLIC 会把这个 flag 传播到链接了这个库的 `main` 可执行文件上，而 `main` 的依赖项中有两个都引入了这个库的头文件，会导致重复定义。把 `PUBLIC` 改成 `PRIVATE` 即可。不可以用 `INTERFACE`，因为 INTERFACE 可以指定只给链接该库的 exe，而不给库本身的 flag。会传播出去从而导致重复定义。

3. 把 `方法1` 里的 `PUBLIC` 改成 `SHARED` 即可在 Ubuntu 中运行。`ldd` 检测到相应的动态库。但该方法在 Windows 下会报错，可以在生成库的 CMakeList.txt 中添加：

   ```cmake
   if (WIN32)
       set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
   endif()
   ```

#### 作为子模块引入

CMake 通过 `add_subdirectory(<THIRD_LIBRARY-PATH>)` 命令，将第三方库作为 CMake 的子模块引入。然后再需要使用该第三方库的 target 目标中，使用 `target_include_libraries(<TARGET-NAME> PUBLIC <THIRD-LIBRARY)` 命令，链接该第三方库。

#### 作为预安装库引入

不同的第三方库之间必然存在着依赖关系，作为子模块引入的方式不可避免的会出现菱形依赖的问题。包的管理者会为 CMake 的 `find_package` 命令编写该项目的 .cmake 脚本（如：/usr/lib/cmake/TBB/TBBConfig.cmake）能够自动查找所有依赖，并且利用 PUBLIC、PRIVATE 正确处理依赖项。

```cmake
find_package(third_lib REQUIRED)
# 现代 CMake 认为一个 package 包，可以提供多个 libraries 库，又称为 components 组件。
# 可以在寻找第三方库（包）的同时，显示指定需要的组件
find_package(third_lib COMPONENTS component1 component2 REQUIRED)

# 例如：
find_package(TBB REQUIRED COMPONENTS tbb tbbmalloc REQUIRED)
target_link_libraries(myexe PUBLIC TBB::tbb TBB::tbbmalloc)

add_executable(app_executable source-files)
target_link_libraries(app_executable PUBLIC third_lib::component1 third_lib::component2)
```

```cmake
# 只会寻找 Findxxx.cmake，默认搜索路径为 /usr/shared/cmake/Modules
find_package(third_lib MODULE REQUIRED)

# 只会寻找 xxxConfig.cmake，默认搜索路径为 /usr/lib/cmake/xxx
find_package(third_lib CONFIG REQUIRED)

# 不指定 MODULE 或 CONFIG 两者都会尝试，MODULE 优先级更高
find_package(third_lib REQUIRED)
```

寻找 Findxxx.cmake，默认搜索路径为 /usr/shared/cmake/Modules，${CMAKE_MODULE_PATH} 变量中可以追加 path_to/cmake 目录，package_DIR、或者 -Dpackage_DIR 变两均可以实现

${CMAKE_MOUDLE_PATH} 中默认有 /usr/shared/cmake/Modules， /usr/lib/cmake 这个位置时 CMake 和第三方库作者约定俗成的，find_package() 命令是去这里查找包配置文件 xxxConfig.cmake 中的信息。当第三方库安装在非标准的路径下，需要手动设置一个变量：

1. -Dlibname_DIR="path-to-library"
2. set(libname_DIR "path-to=library")

> Windows 要求 exe 和 dll 位于同一目录下。cmake `-DCMAKE_INSTALL_PREFIX=path` 指定 `--build build --target install` 安装时拷贝的路径为 `path/lib` 下

## 目录组织格式

- （子、具体）项目名/include/项目名/模块名.h
- （子、具体）项目名/src/模块名.cpp
- （子、具体）项目名/CMakeLists.txt
- （根）项目名/CMakeLists.txt

> （子、具体）项目名/include/项目名/*.h 在项目名目录的 include 目录下再次引入项目名目录，是为了使用 `#include<header>` 头文件名中，header 有 `项目名/*.h` 的前缀，防止冲突。

CMakeLists.txt：

```cmake
# 不推荐使用 inlcude_diretories()，容易污染。
target_include_directories(项目名 PUBLIC include)
```

头文件（项目名/include/项目名/模块名.h）：

```c++
#pragma once
namespace 项目名{
    void 函数名()；
}；
```

源文件（项目名/src/模块名.cpp）：

```c++
#include<项目名/模块名.h>
namespace 项目名{
    void 函数名(){
        //implementation
    }
}；
    
项目名::函数名();
```

大型项目，往往会划分为几个子项目，各自目录下有自己的 CMakeLists.txt。一个项目，至少可分为库项目、可执行项目。库项目提供实现，也可以被其他项目所引用。

项目根目录的 CMakeLists.txt 中，设置了默认的构建模式（Debug、Release）设置了 C++ 版本等各种项目选项，然后通过 project() 命令初始化（根）项目，再通过 add_subdirectory() 命令把子项目添加进来。

```cmake
# 项目根目录 CMakeLists.txt
cmake_minimum_required(VERSION 3.17)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 上述 set() 命令，应该置于 project() 命令前。
project(CPPExample LANGUAGES C CXX)

add_subdirectory(subproject1)
add_subdirectory(subproject2)
add_subdirectory(xxxlib)
```

子项目目录的 CMakeLists.txt 中，通过 target_include_directories() 命令设置头文件搜索路径都是相对路径、且在命令中使用 PUBLIC 修饰符，使（链接）该项目的其他项目也能够共享该项目的头文件搜索路径。

```cmake
# CONFIGURE_DEPENDS 可以实现自动更新
file(GLOB[_RECURSE] srcs CONFIGURE_DEPENDS src/*.cpp include/*.h)
add_library(xxxlib [STATIC|SHARED] "${srcs}")
target_include_directories(xxxlib PUBLIC include)
```

```cmake
# CONFIGURE_DEPENDS 可以实现自动更新
file(GLOB[_RECURSE] srcs CONFIGURE_DEPENDS src/*.cpp include/*.h)
add_executable(app_executable "${srcs}")
target_include_directories(app_executable PUBLIC include)

target_link_libraries(app_executable PUBLIC xxxlib)
```

通常每个头文件都有一个对应的源文件，两个文件的名字应该相同，只有后缀名不通。如果是一个类，则文件名应该和类名相同，方便查找。头文件中包含函数的声明、类的定义，源文件包含它们的实现。但模板的声明和实现应该放在同一个头文件中去。

> 注意：在头文件中直接实现函数时，要加 static 或 inline 关键字。类定义中定义的函数，编译器自动添加 inline 属性。另外，每个头文件中都应该加上头文件保护机制（`#ifndef`、`#pragma once`）

#### 古今 CMakeLists.txt

```cmake
# 古代
find_package(<PACKAGE_NAME>)
if(NOT <PACKAGE_NAME>_FOUND)
	message(FATAL_ERROR "<PACKAGE_NAME> not found")
endif()

target_include_directories(<EXE_NAME> ${<PACKAGE_NSME>_INCLUDE_DIRS})
target_link_libraries(<EXE_NAME> ${<PACKAGE_NAME>_LIBRARIES})

# 现代
find_package(<PACKAGE_NAME> COMPONENTS <components...> REQUIRED)
target_link_libraries(<EXE_NAME> PACKAGE::component)
```

#### 标准 CMakelists.txt

```cmake
cmake_minimum_required(VERSION 3.27)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(rpc LANGUAGES C CXX)

if (PROJECT_BINARY_DIR STREQUAL PROJECT_SOURCE_DIR)
	message(WARNING "The binary directory of CMake cannot be the same as source directroy!")
endif()

if (WIN32)
	add_definitions(-DNOMINMAX -D_USE_MATH_DEFINES)
endif()

if (NOT MSVC)
	find_program(CCACHE_PROGRAM ccache)
	if (CCACHE_PROGRAM)
		message(STATUS "FOUND CCache: ${CCACHE_PROGRAM}")
		set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_PROGRAM})
		set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_PROGRAM})
	endif()
endif()
```

> message(STATUS "...") 会在输出前追加 "-- "，不会突出显示信息。
>
> 清除缓存，其实只需要删除 build/CMakeCache.txt 就可以了，除非中间文件需要更新。

# Makefile

**一般的程序都是由多个源文件（头文件）编译、链接而成的**，对于中大型工程来说，由于包含了大量的源文件，如果每次改动都需要编译所有的源文件，这种方式效率太低。make 工具就是为了解决上述问题而出现的，它会重新编译所有受到改动影响的源文件，而非所有源文件。

如果在当前工作目录下直接运行 `make` 命令，那么 `make` 命令会在当前目录下查找名为 `makefile` 或 `Makefile` 的文件。为了显示指定 `make` 命令使用哪个文件作为 makefile 文件，可以使用 `-f` 选项。make 一般用于 C/C++ 工程的编译、链接过程，而解释性语言工程并不需要。

Makefile 文件利用文件的时间戳属性，来管理程序编译的过程，以节省程序编译时间，提高项目编译效率。Makefile 通过将一系列 prerequisites(*dependencies*) 依赖和 target 目标结合在一起构成一条 rule 规则作为 target 目标，完成程序的编译。`make` 命令如果没有指定具体的 target 目标作为参数，则会默认以第一条 target 目标作为目标。

```makefile
# A rule generally looks like this:
targets: prerequisites
	command
	command
	command
# Makefiles must be indented using TABs and not spaces or make will fail.
```

> make target 会根据 target 是否存在，以及 target 和 prerequisites(*dependencies*) 依赖文件的时间戳，递归执行各个 target。

### make 命令

```bash
$ make [options]
```

`-j` 选项：指定并发线程数。

`-B` 选项：无条件执行所有 target 目标。

`-f` 选项：执行指定 <makefile\> 文件（参数给出）

`-C` 选项：进入指定目录中，调用其中的 makefile 文件。 

`-n` 选项：打印出执行 make 后要执行的命令，但不会真正执行命令。

由于 Makefile 不是顺序执行的，使用 `-n` 选项可以先看看命令的执行顺序，确认无误了再真正执行命令。另外，`-nB` 选项通常可以共同使用

一些规模较大的项目会把不同的模块或子系统的源代码放在不同的子目录中，然后在每个子目录下都写一个关于该目录的 Makefile，然后在项目的根目录下的 Makefile 中用 `make -C` 命令执行每个子目录下的 Makefile。

在 `make` 命令中，可以使用 `=` 或 `:=` 定义变量。如果这次编译需要添加调试选项 `-g`，但不想每次编译都需要添加 `-g` 选项，则可以在这次执行 `make` 命令时定义 `CFLAGS` 变量。如果在 Makefile 中也定义了 `CFLAGS` 变量，则**命令行中定义的变量值会覆盖 Makefile 中定义的变量值**。

```bash
$ make CFLAGS=-g 
```

> `man make`、`info make` 或者在线手册中，有关于 make 命令的所有信息。根据 make 命令的本质，它可以用于检测到依赖更新后，自动执行相关命令的工作。

### 编译、链接

只要源文件的语法正确，编译器就可以编译出对应的中间目标文件（.o 文件）一般来说，每个源文件都会对应于一个中间目标文件（ .o 文件） 

链接时，主要是链接程序的**（非 static ）全局函数和全局变量**符号。由于链接器并不知道全局函数和全局变量所在的目标文件、库文件（.a 文件、.so 文件）因此会在编译命令所指定的源文件和库文件中**依次寻找**。 

总结一下：**编译时，编译器只会检查各个源文件的语法（如：函数、变量是否被声明）**。而在**链接时，链接器则会在所有的目标文件（ .o 文件）和库文件（.a 文件、.so 文件）中找寻所有全局函数和全局变量的实现**，如果找不到，或者重复定义，则会报链接错误。

> 由于动态库是 PIC 位置无关代码，需要**向链接器指定动态库所在目录**，执行时动态加载其在内存中的位置。

运行时链接器（Linux 上为 ld.so）必须知道动态链接库的位置：

1. LD_PRELOAD 环境变量
2. LD_LIBRARY_PATH 环境变量
3. -Wl,-rpath=<dir\> 编译选项，将 \<dir> 动态库目录写进 binary(executable) 可执行文件中
4. 编辑 `/etc/ld.so.conf` 文件，执行 `ldconfig` 命令，指定（动态）运行时链接器（Linux 上为 ld.so）搜索动态链接库的目录。

> Makefile 中，-Wl,-rapth=<dir\> 通常搭配 -L /path/to/library 和 -llibname 共同使用。

### Makefile 的编写

`make` 命令带来的好处就是——“**自动化编译**”，一旦写好 Makefile，只需要一个 `make` 命令，整个工程便会完全自动编译。**Makefile 文件内定义了整个工程的编译规则**。

一个工程中的源文件不计其数，并且按类型、功能分不同模块放在若干个子目录中。每个子目录下都会写一个关于该目录的 Makefile 文件定义了该目录下的编译规则：<u>**文件的编译规则、依赖规则**</u>。

几乎所有 makefile 文件都会定义 macro 宏、rule 规则：

#### 宏

宏的定义类似于变量的定义，但是宏的属性是常量，不可修改的。使用宏值时，需要将宏名置于 `$()` 内，可以在替换旧宏内容的基础上创建一个新宏，例如。

```makefile
OBJ = $(SRC:.c=.o)
```

> 通过键入 `make -p` 命令，可以查看 make 工具所有的预设隐含规则，及其内置预定义宏。`make -r` 命令可以取消所有的预置隐含规则，及其内置预定义宏。

#### 规则  

除了 macro 宏定义，Makefile 主要由一系列 rule 规则组成，其中，每条规则（rule）的格式是：

```makefile
targets: prerequisites
	command
	command
	command
```

每条 rule 规则由 targets 目标、prerequisites 依赖、commands 命令三部分组成，其中如果一条 rule 规则有多个 targets 目标时，将根据相同的 prerequisites 依赖，针对每个 target 目标运行相同的 commands 命令。 $@ 是一个自动变量，常用于 command 中，包含其所在 target 对应的（单个）目标名称。

```makefile
f1.txt f2.txt: hello.txt
	echo $@
	touch $@
# Equivalent to:
# f1.txt: hello.txt
#	 echo f1.txt
#	 touch $@
# f2.txt: hello.txt
#	 echo f2.txt
#	 touch $@
```

> 注意：每条 rule 规则中的 prerequisites 依赖关系，用空格分隔。每条 command 命令单独成行，位于行首且前面必须有 [TAB]。 

- **target**	

target 目标可以是一个**文件**，还可以是一个**标签（label）**欲执行 commands 更新 target，则必须先检查它所依赖的内容 prerequisites；只要依赖关系种有一个条件更新了，则目标也必须随之被更新。

Makefile 文件的 target 目标是 make 工具的核心： 它们根据 prerequisites 依赖关系将 make 命令转换为一系列具体的 commands 命令动作。例如：`make clean` 命令告诉 make 执行 Makefile 中的 clean 目标相关的 commands 命令动作

- **prerequisites**	

prerequisites 依赖为生成 target 所需的条件，如果 prerequisites 依赖中有一个及其以上的时间（戳）比 target 目标要新，或者 target 目标不存在的话，则该条规则的 commands 命令会被执行一遍。如果 prerequisites 中有依赖中有一个及其以上的内容不存在，就会递归地执行以其为 target 目标的 rule 规则，直到可以生成规则中的目标。

> 一条 rule 规则中的 prerequisite 依赖可以是文件，或者是另一条 rule 规则的 target 目标。

- **command**

行首键入 [TAB] 后，键入完成 target 所需要执行的 command 命令（任意的 Shell 命令)  **所谓更新 target 目标就是执行一遍 rule 规则中的 commands 命令列表**。对于 rule 规则中，每个以 Tab 开头的 command 命令，make 都会创建一个 Shell 子进程去执行它。但因为 prerequisite 依赖不存在而递归执行其他 rule 规则 target 目标时，当前 rule 规则中的命令列表会被压栈。

```makefile
# According line to run a new shell to execute command
all: 
	cd ..
	# The cd above does not affect this line, because each command is effectively run in a new shell
	echo `pwd`

	# This cd command affects the next because they are on the same line
	cd ..;echo `pwd`

	# Same as above
	cd ..; \
	echo `pwd`
```

Makefile 中，**第一条 rule 规则的 target 目标称为 default target 缺省目标，只要缺省目标完成更新了就算完成 make 命令的任务了**，其它工作都是为这个 target 目标而做的。另外，一个目标所依赖的所有条件不一定非得写在一条规则中，也可以拆开写。**<u>如果同一个目标拆开写多条规则，其中只有一条规则允许有命令列表，其它规则应该没有命令列表</u>**，否则 `make` 会报警告并且采用最后一条规则的命令列表。

如果一条 rule 规则的 target 目标属于以下情况之一，就称为需要更新（执行具体的 commands 命令列表）：

1. 目标没有生成。
2. 某个条件的修改时间比目标新。
3. 回溯以该目标为条件的规则，需要更新。

执行一条规则 R 的步骤如下：

1. 在检查完规则 R 的所有依赖条件 P 后，检查它的目标 T，如果属于以下情况之一，就执行它的命令列表：
   - 文件 T 不存在。
   - 文件 T 存在，但是某个依赖条件 P 的修改时间比它新。
2. 检查规则 R 的每个依赖条件 P：
   - 如果存在以 P 为目标的规则，则递归执行以 P 为目标的规则 。
   - 如果找不到以 P 为目标的规则，并且 P 不以文件形式存在，则报错退出。
   - 如果找不到以 P 为目标的规则，但 P 以文件形式存在，则检查 P 的存在与新旧。

> Makefile 就是一个包含多条 rule 规则的文件，make 是 rule 规则的解释执行者。可以类比 shell 命令/脚本和 bash 命令解释器的关系。

> 需要注意的是，**规则中每条命令在一个单独的 Shell 中执行。这些 Shell 之间没有继承（父子）关系**。如果需要在同一 Shell 中执行，需要用 ; 分号结合 \ 转义换行符、或者在规则前加上 `.ONESHELL:` 命令。

#### 匹配符

- *

  `*` 总是需要在 `$(wildcard *.c)` wildcard 函数中使用

- %

  

#### .PHONY 伪目标

```makefile
# clean 伪目标。即 target 是一个 label 标签，而非（目标、可执行）文件。
.PHONY : clean

clean ：
	@echo "cleanning project"
	-rm -rf ...
	@echo "clean completed"
```

**.PHONY 伪目标表示，这个 target 目标不是一个要生成文件的 rule 规则**。`.PHONY:clean` 定义了 clean 这个 target 是一个 label 标签，是一个 .PHONY 伪目标。在这种情况下，即使当前目录下有 clean 文件，它也仍然会执行该条 rule 规则，因为只是一个标签，并不需要生成文件。

像上例中 clean 这样的伪目标，由于 **prerequisites 中并没有指定任何依赖关系，make 命令不会（递归）查找它的依赖性**。由于 clean 伪目标指明了其为标签的本质，要执行该条 rule 规则的 command 命令，就要在 make 命令中显示指定该条 rule 规则的 target 命令，即该 label，如 `make clean`。否则 make 不会执行该条 rule 规则所定义的 commands 命令。

> `make` 命令就不会判断 .PHONY 伪目标是否需要更新，伪目标相应的 commands 命令序列总是会被执行。

每个 Makefile 文件中都应该写一个用于清除编译过程中产生的二进制文件，保留源文件的 **clean 伪目标** 。一条不成文的规矩是：clean 规则从来都是放在 Makefile 文件的最后且格式固定。而在 echo 命令前面加一个 `@` 字符的意思就是，不会输出命令本身而只输出它的结果。在 rm 命令前面加一个 `-` 字符的意思就是，也许某些文件出现问题，但不要管，**强制执行 `-` 后面的命令**。  

> clean 规则的命令列表中。通常 `rm` 命令和 `mkdir` 命令前面要加 `-` 号，因为`rm` 要删除的文件可能不存在，`mkdir` 要创建的目录可能已存在，这两个命令都有可能出错，但这种错误是应该忽略的。

makefile 中其他不成文规定的 .PHONY 伪目标：    

1. `.PHONY : all` : 伪目标，功能是依次编译所有的 target 目标。
2. `.PHONY : clean` : 伪目标，功能是删除 make 过程中所创建的所有编译、链接文件。
3. `.PHONY : install` : 伪目标，功能是安装编译好的二进制应用程序，所以通常依赖于生成可执行程序的目标规则，将编译成功的应用程序安装到指定目录下。

### Makefile 的语法

输入 `make` 命令后:  

1. make 会在当前目录下找名字叫 “Makefile” 或 “makefile” 的文件。  
2. 如果找到相关文件，make 命令会再去找文件中的**第一条规则（rule）的目标（target）**并把这个目标文件作为最终生成的文件。 
3. 如果**目标文件不存在**，**依赖文件不存在**或是**目标文件所依赖的文件比目标文件新**，那么 make 命令就会递归执行以依赖为目标的规则和本条规则中的命令来生成目标文件。  

如果**依赖文件不存在**。且 makefile 文件中没有以依赖文件为目标的规则，则 make 会报错退出。makefile 一般都是以目标为中心，一个目标依赖于若干条件。

> **make 会在 Makefile 中一层一层地递归寻找依赖关系，直到能顺利编译出第一条规则中的目标文件。**注意：这里的目标（和规则）为普通目标（规则），伪目标的本质仅起到标签的作用，并不能生成任何文件。

#### Makefile 宏

Makefile 宏本质上就是一个文本字符串，因为不可以修改，所以理解成 C 语言中的宏（常量）可能会更好。Make file 的宏定义使用赋值符号：`MACRO = value`、引用宏的值使用 dollar 符号加 parentheses 小括号：`$(MACRO)`

Makefile **每条规则都有预定义好的 macro 宏**。这些特殊的预定义宏也成为自动变量，它们基于当前 rule 规则中的 target 目标和 prerequisites 依赖。这些预定义宏只应该出现在每个 rule 规则的 commands 命令列表中。下面对常见的预定义宏进行说明：  

- `$*` 表示规则中**目标的文件名**（去后缀） 
- `$@` 表示规则中**目标的文件名**（不去后缀）  
- `$^` 表示规则中**所有依赖文件的集合**，以空格分隔（会去重） 
- `$+` 表示规则中**所有依赖文件的集合**，以空格分隔（不会去重）
- `$?` 表示规则中**比目标文件新的依赖文件的集合**，以空格分隔。
- `$<` 表示规则中**依赖文件的第一个文件**，但**如果目标和依赖是以模式规则定义的，$< 则是符合模式规则的依赖文件的集合**。

> 模式规则：在 rule 规则的 target 目标中如果包含 `%` 字符，`%` 可以表示一个或多个文件，在 rule 规则的 prerequisites 依赖中同样可以使用 `%` 表示相同内容，取值决于其目标中的值。

Makefile 中的宏

仅在使用命令时查找变量，而不是在定义命令时查找。
就像普通的命令式编程--只有目前定义的变量才会被扩展

1. macro = value 方式递归定义宏。**表示使用宏时计算宏的值，而不是在定义时计算**
2. macro := value 方式简单扩展宏。**表示计算式，宏不能递归使用 value 中的宏定义**。  
3. macro ?= value 方式定义条件宏。**表示如果宏 macro 没有被定义过，那么那么宏 macro 的值就是 value，否则这条语句什么也不做**。    

```makefile
# Recursive variable. This will print "later" below
one = one ${later_variable}
# Simply expanded variable. This will not print "later" below
two := two ${later_variable}
# one gets defined as a simply expanded variable (:=) and thus can handle appending
three := ${three} three

later_variable = later

all: 
	echo $(one)
	echo $(two)
	echo $(three)
```

> 多使用 `:=`，是因为 **`=` 定义的宏的值具有<u>递归展开</u>特性**，有可能写出无穷递归的定义。

makefile 文件中定义的宏，位于所有 rule 规则外，都具有全局属性。 也可以为某个 target 目标设置局部定义的宏，则它的作用范围只在这条 rule 规则及其规则链中，例如：  

```  makefile
# <target> : <macro-definition>  
all: one = cool

# 如果同一个目标拆开写多条规则，其中只有一条规则允许有命令列表，其它规则应该没有命令列表
all: 
	echo one is defined: $(one)

other:
	echo one is nothing: $(one)
```

对于多目标的规则，`make` 会拆成几条单目标的规则来处理，例如：

```makefile
target1 target2: prerequisite1 prerequisite2
	command $< -o $@
	
# 这样一条规则相当于：

target1: prerequisite1 prerequisite2
	command $< -o $@

target2: prerequisite1 prerequisite2
	command $< -o $@
```

> 注意：多目标规则拆分的当目标规则的依赖和命令是一样的，但因为 目标不通，`$@` 的取值不同。

#### makefile 逻辑  

**条件表达式的语法如下：**

```makefile
<conditional-directive>
	command
else
	command
endif 
```
endif 表示一个条件语句的结束，<conditonal-directive\> 条件的四个关键字：

1. ifeq
2. ifneq
3. ifdef
4. ifndef

任何一个条件表达式都应该以 endif 结束。**由于 make 在读取 Makefile 时就计算条件表达式的值，而自动变量则在运行时才会有。因此不要把自动化变量放入条件表达式中**。自动变量永远只能在一条 rule 规则的 commands 命令中。

#### makefile 函数 

Makefile 中的函数主要用于文本处理，函数调用的语法如下：

```makefile
$(<function> <arguments>)
```

函数调用很像宏取值，函数中的参数也可以使用宏，函数调用以 $ 开头，() 将 <function\> 和 <arguments\> 括起来。<function\> 和 <arguments\> 间**以空格分隔**。<arguments\> 函数参数间**以逗号分隔**。  

```makefile
foo := a.o b.o c.o hello.txt
one := $(patsubst %.o,%.c,$(foo))
# This is the shorthand for the above
two := $(foo:%.o=%.c)
# This is the suffix-only shorthand, and is also equivalent to the above
three := $(foo:.o=.c)

all:
	echo $(one)
	echo $(two)
	echo $(three)
```

```makefile
foo := $(if this-is-not-empty,then!,else!)
empty :=
bar := $(if $(empty),then!,else!)

all:
	@echo $(foo)
	@echo $(bar)
```

```makefile
obj_files := foo.result bar.ol lose.o
filtered_files := $(filter %.o, $(obj_files))

all:
	@echo $(filtered_files)
```

> 可以同时过滤多个模式。 例如：`$(filter %.c %.h, $(files))`  将从文件列表中选择所有 .c 和 .h 文件。

#### makefile 的模式规则 

模式规则中，target-pattern 目标里必须要有匹配 % 的字符。% 表示一个或多个任意字符，用来表示对 targets... 内容的匹配。在 prereq-patterns 依赖中同样可以使用 %。

```makefile
targets...: target-pattern: prereq-patterns ...
	commands
```

#### Makefile 的隐式规则

一般情况下，显示永远优于隐式。如果在 Makefile 中，某个 target 目标所在 rule 规则，没有 commands 命令列表或者某个 prerequisite 依赖没有对应的 rule规则，make 则会尝试在内建的隐式规则（Implicit Rule）数据库中查找适用的规则。可以通过改变系统预定义宏的值来定制隐含规则运行时的参数。

1. 编译 C 程序的隐含规则 

   <filename\>.o 目标的依赖会自动推导为 <filename\>.c 

   生成目标的命令是：`$(CC) -c $(CFLAGS) $^ -o $@` 

2. 编译 C++ 程序的隐含规则 

   <filename\>.o 目标的依赖会自动推导为 <filename\>.cc 或者 <filename\>.cpp

   生成目标的命令是：`$(CXX) -c $(CXXFLAGS) $^ -o $@` 

3. 汇编文件的另一条隐含规则

   <filename\>.o 目标的依赖会自动推到为 <filename\>.s 

   生成目标的命令是：`$(AS) $(ASFLAGS) $^ -o $@` 

4. 可执行文件的另一条隐含规则

   <filenmae\> 可执行文件依赖会自动推导为单一目标文件 <filename\>.o

   生成目标的命令为：`$(CC) $(LDFLAGS) $^ $(LOADLIBES) $(LDLIBS) -o $@`

> 使用模式匹配时，命令中必须使用自动变量进行操作。

### Colored Egg

Makefile 中使用 $(MAKE) 替换 make 递归调用 make。

`#` 符号在 makefile 中表示单行注释，就像 C 语言的 `//` 注释一样。

只有当文件没有明确的依赖关系或规则，那么 make 才会尝试使用模式规则（如 %c）来处理它。

```makefile
TARGET_EXEC := program

SRC_DIR := ./src
BUILD_DIR := ./build

# Find all the C and C++ files we want to compile
# Note the single quotes around the * expressions. The shell will incorrectly expand
# these otherwise, but we wanna send the * directly to the find command
SRCS := $(shell find $(SRC_DIR) -name "*.cpp" -or -name "*.c" -or -name "*.s")

# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./src/<dir>/hello.cpp turns into ./build/<dir>/hello.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# String substitution (suffix version without %)
# As an example, ./build/hello.cpp.o turns into ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# Every folder in ./src will need to be passed to GCC so that it can find header files
INC_DIRS := $(shell find $(SRC_DIR) -type d)
# Add a prefix to INC_DIRS. so moduleA would become -ImoudleA. GCC need it to -I flag
INC_FLAGS := $(addprefix -I, $(INC_DIRS))

# The -MMD and -MP flags together generate Makefiles for header files
# These files will have .d instead of .o as the output
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# The final build step.
$(BUILD_DIR)/$(TARGET_EXEC) : $(OBJS)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)
	
# Build step for C source
$(BUILD_DIR)/%.c.o : %.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
	
# Build step for C++ source
$(BUILD_DIR)/%.cpp.o : %.cpp
	@makedir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@
	
.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
	
# Include the .d makefiles. The - at the front suppresses the errors of missing Makefiles
# Initially, all the .d files will be missing, and we don't want those errrors to show up
-include $(DEPS)
```

