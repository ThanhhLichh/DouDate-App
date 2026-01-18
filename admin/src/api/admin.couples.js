import axios from "./axios";

export async function getCouples() {
  const res = await axios.get("/admin/couples");
  return res.data;
}


export async function breakCouple(coupleId) {
  const res = await axios.post(`/admin/couples/${coupleId}/break`);
  return res.data;
}