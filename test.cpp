////////////////////////////
vec abc;
vec* abc;
vec *abc;
vec& abc;
vec &abc;
customtype baselen, prefixlen;
ptrdiff_t *baselen, *prefixlen;
ptrdiff_t &baselen, &prefixlen;
test<a, b, c>{};
int a[10];
auto a = [b](int a, vec b) -> int {};
auto a = std::vector<int>{};
auto a = std::vector<vec>{};
auto& [abc, def] = std::vector<vec>{};
////////////////////////////
BVAR (current_buffer, directory);
eassert (0 < vfork_error);
eassert (a* vfork_error);
eassert (a *vfork_error);
eassert (a &vfork_error);
eassert (a& vfork_error);
////////////////////////////
if (std_err < 0);
if (std_err > 0);
if (std_err * 0);
if (std_err / 0);
if (std_err & 0);
if (std_err | 0);
////////////////////////////
template <typename F, typename B>
auto add(F, B);

void test2(vec a, vec2 b, vec3);
void* test2(vec a, vec2 b, vec3);
void& test2(Fn&& a, vec2 b, vec3);
ttt abc(vec* a, vec2 *b, vec3& c, vec4 &d);
auto abc(vec* a, vec2 *b, vec3& c, vec4 &d) -> int;

Lisp_Object get_abc(Lisp_Object object, bool error_if_not_keymap, bool autoload);

std::is_function_v<std::remove_pointer_t<Fn>>;

InvokeHelper(const Fn& callback) : callback(callback) {}

InvokeHelper(Fn&& callback) : callback(std::move(callback)) {}

explicit Webview2ComPtr(Fn callback) : UnwrapArguments<Base, Fn>::Forward(std::move(callback)) {}

(*test3)(vec a, vec2, vec3 c, vec4);
(*test4)(vec* a, vec2&& b, vec3 *c, vec4);
(*test4)(vec& a, vec2, vec3 &c, vec4);
////////////////////////////}
