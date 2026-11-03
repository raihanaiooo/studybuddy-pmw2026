export function Button({ children, onClick, primary, type = 'button' }: any) {
  return (
    <button
      type={type}
      onClick={onClick}
      className={`px-4 py-2 rounded-lg font-bold transition-all active:scale-95 ${
        primary
          ? 'bg-[var(--blue)] text-white hover:bg-[#1A5EAA]'
          : 'bg-[var(--card)] border border-[var(--line)] text-[var(--ink)] hover:bg-[var(--hov)]'
      }`}
    >
      {children}
    </button>
  );
}