import { Outlet } from "react-router-dom";

export default function AdminLayout() {
  return (
    <>
      <h1>Admin Layout</h1>
      <Outlet />
    </>
  );
}
