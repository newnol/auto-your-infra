# 🐙 Skill: GitHub & Git Operations cho AI Assistant

Tài liệu này định nghĩa các nguyên tắc và lệnh chuẩn để các AI/Agent tự động thao tác với repository GitHub trong hệ thống DevOps/GitOps này. Các AI phải tuân thủ nghiêm ngặt các nguyên tắc dưới đây khi được yêu cầu tương tác với mã nguồn.

## 1. Nguyên tắc cốt lõi (Core Principles)
- **Bảo mật tuyệt đối:** KHÔNG BAO GIỜ commit các secret, token, mật khẩu, file `.pem`, `.key`, `kubeconfig` thật, hoặc `.vault_pass` vào repository.
- **Conventional Commits:** Bắt buộc sử dụng chuẩn Conventional Commits cho các commit message để dễ dàng tracking (ví dụ: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`).
- **Verify State:** Luôn sử dụng `git status`, `git diff`, và `git branch` để kiểm tra trạng thái của repo trước khi thực hiện add, commit, hay push.

## 2. Quy trình làm việc tiêu chuẩn (Standard Workflow)
1. **Kiểm tra trạng thái nhánh:** `git status`
2. **Đồng bộ mã nguồn (nếu cần):** `git pull origin main`
3. **Thêm thay đổi:** Sử dụng `git add <đường-dẫn-file>` (hạn chế dùng `git add .` nếu không chắc chắn toàn bộ file đều an toàn).
4. **Commit:** `git commit -m "<type>: <mô-tả-ngắn-gọn>"`
5. **Push:** `git push origin <tên-nhánh>`

## 3. Sử dụng GitHub CLI (gh)
Nếu môi trường có cài đặt `gh` CLI, AI có thể sử dụng các lệnh sau để hỗ trợ quy trình CI/CD:
- **Kiểm tra đăng nhập:** `gh auth status`
- **Quản lý Pull Request:** `gh pr create --title "<tiêu-đề>" --body "<nội-dung>"`
- **Kiểm tra GitHub Actions:** `gh run list` hoặc `gh run watch`

## 4. Tương tác với hệ thống GitOps (ArgoCD)
Dự án này sử dụng ArgoCD quản lý môi trường `dev` và `staging` theo triết lý GitOps. Do đó:
- AI **KHÔNG** dùng lệnh `kubectl apply` để tự deploy các file manifest của ứng dụng (ngoại trừ thao tác bootstrap infra/RBAC ban đầu).
- Thay vào đó, AI chỉ cần cập nhật tag của Docker Image bên trong các thư mục `kubernetes/overlays/dev` hoặc `kubernetes/overlays/staging`.
- Commit và Push sự thay đổi file YAML này lên GitHub. ArgoCD sẽ tự động bắt lấy commit và sync cấu hình mới xuống Kubernetes Cluster.
