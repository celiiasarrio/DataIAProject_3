import { Eye, EyeOff } from 'lucide-react';
import { useState } from 'react';
import { useNavigate } from 'react-router';
import { login, getMyProfile, mapRol } from '../api/client';
import { LoadingSpinner } from './ui/LoadingSpinner';

export function LoginScreen() {
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const tokenData = await login(email, password);
      localStorage.setItem('token', tokenData.access_token);

      const profile = await getMyProfile();
      localStorage.setItem('userRole', mapRol(profile.rol));
      localStorage.setItem('userId', profile.id);
      localStorage.setItem('userName', `${profile.nombre} ${profile.apellido}`);
      localStorage.setItem('userEmail', profile.correo);
      if (profile.url_foto) localStorage.setItem('userPhoto', profile.url_foto);

      navigate('/dashboard');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error al iniciar sesión');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-[#f5f5f5] px-6">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-12">
          <h1 className="text-5xl text-[#008899] mb-2" style={{ fontWeight: 300, fontFamily: 'Didot, Bodoni, serif' }}>EDEM</h1>
          <p className="text-sm text-gray-600">EDEM STUDENT HUB</p>
        </div>

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-4">
          {/* Email Input */}
          <div>
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="off"
              className="w-full px-4 py-3 border-b-2 border-gray-300 bg-transparent focus:outline-none focus:border-[#008899] placeholder:text-gray-400"
            />
          </div>

          {/* Password Input */}
          <div className="relative">
            <input
              type={showPassword ? 'text' : 'password'}
              placeholder="Contraseña"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="off"
              className="w-full px-4 py-3 border-b-2 border-gray-300 bg-transparent focus:outline-none focus:border-[#008899] placeholder:text-gray-400 pr-10"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-2 top-1/2 -translate-y-1/2 text-gray-400"
            >
              {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
            </button>
          </div>

          {/* Remember Me Toggle */}
          <div className="flex items-center justify-between py-2">
            <span className="text-sm text-gray-600">Recordarme</span>
            <button
              type="button"
              onClick={() => setRememberMe(!rememberMe)}
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                rememberMe ? 'bg-[#008899]' : 'bg-gray-300'
              }`}
            >
              <span
                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                  rememberMe ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </button>
          </div>

          {/* Error message */}
          {error && (
            <p className="text-red-500 text-sm text-center">{error}</p>
          )}

          {/* Login Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full bg-[#008899] text-white py-3 rounded-lg mt-6 hover:bg-[#007788] transition-colors disabled:opacity-60"
          >
            {loading ? <LoadingSpinner size="sm" tone="white" /> : 'Login'}
          </button>
        </form>
      </div>
    </div>
  );
}
