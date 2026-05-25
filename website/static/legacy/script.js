const name = "yaya@";
const domain = "bernstein-plus-sons";
const domext = ".com";
const email = name + domain + domext;

export function updateEmails() {
  const placeholders = document.querySelectorAll('.email-placeholder');
  placeholders.forEach(el => {
    if (el.childNodes.length === 0) {
      const a = document.createElement('a');
      a.href = "mailto:" + email;
      a.textContent = email;
      el.appendChild(a);
    }
  });
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', updateEmails);
} else {
  updateEmails();
}
